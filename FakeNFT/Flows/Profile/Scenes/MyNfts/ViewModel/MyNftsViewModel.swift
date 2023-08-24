enum MyNftsEvents {
	case showErrorAlert(String, withRetry: Bool)
	case showSortAlert
	case close
}

enum MyNftsRequest {
	case selectSort
	case selectSortBy(SortMyNftsBy)
	case retryAction
	case goBack
}

protocol MyNftsViewModelInput: AnyObject {
	var didSendEventClosure: ((MyNftsEvents) -> Void)? { get set }

	func viewIsReady()
	func didUserDo(request: MyNftsRequest)
}

protocol MyNftsViewModelOutput: AnyObject {
	var items: Observable<[Nft]> { get }
	var authors: Observable<[Author]> { get }
	var likes: Observable<[String]> { get }
	var isLoading: Observable<Bool> { get }
	var numberOfItems: Int { get }
	var isEmpty: Bool { get }
	var cellModels: [ICellViewAnyModel.Type] { get }

	func cellModelAtIndex(_ index: Int) -> ICellViewAnyModel
}

typealias MyNftsViewModel = (
	MyNftsViewModelInput &
	MyNftsViewModelOutput
)

final class DefaultMyNftsViewModel: MyNftsViewModel {
	struct Dependencies {
		let profile: Profile
		let getMyNfts: GetNftsProfileUseCase
		let getSetSortOption: SortMyNtfsOption
		let putLikes: PutLikesProfileUseCase
		let getAuthors: GetAuthorsUseCase
	}
	private let dependencies: Dependencies
	private var retryAction: (() -> Void)?

	// MARK: - INPUT
	var didSendEventClosure: ((MyNftsEvents) -> Void)?

	// MARK: - OUTPUT
	var items: Observable<[Nft]> = Observable([])
	var authors: Observable<[Author]> = Observable([])
	var likes: Observable<[String]> = Observable([])
	var isLoading: Observable<Bool> = Observable(false)

	var numberOfItems: Int { items.value.count }
	var isEmpty: Bool { items.value.isEmpty }
	var cellModels: [ICellViewAnyModel.Type] = [MyNftsItemCellModel.self]

	// MARK: - Inits

	init(dep: Dependencies) {
		dependencies = dep
		likes.value = dep.profile.likes
	}
}

// MARK: - OUTPUT

extension DefaultMyNftsViewModel {
	func cellModelAtIndex(_ index: Int) -> ICellViewAnyModel {
		let nft = items.value[index]
		let isFavorite = likes.value.contains(nft.id)
		let author = authors.value.first { $0.id == nft.authorID }?.name ?? ""
		let price = Theme.getPriceStringFromDouble(nft.price)

		return MyNftsItemCellModel(
			avatarImageURL: nft.cover,
			isFavorite: isFavorite,
			title: nft.name,
			rating: nft.rating,
			author: author,
			price: price,
			onTapFavorite: { [weak self] in self?.likeItemWithID(nft.id) }
		)
	}
}

// MARK: - INPUT. View event methods

extension DefaultMyNftsViewModel {
	func viewIsReady() {
		isLoading.value = true

		// первоначально загрузим nfts тем что есть в profile
		// ??? let sortBy = dependencies.getSetSortOption.sortBy
		let nftIDs = dependencies.profile.nfts
		dependencies.getMyNfts.invoke(nftIDs: nftIDs) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let nfts):
				self.items.value = nfts
				self.sortMyNfts()
				self.fetchAuthors()
			case .failure(let error):
				self.items.value = []
				self.retryAction = { self.viewIsReady() }
				self.didSendEventClosure?(
					.showErrorAlert(error.description, withRetry: true)
				)
			}

			self.isLoading.value = false
		}
	}

	func didUserDo(request: MyNftsRequest) {
		switch request {
		case .selectSort:
			guard items.value.count > 1 else { return }
			didSendEventClosure?(.showSortAlert)
		case .selectSortBy(let sortBy):
			dependencies.getSetSortOption.setOption(sortBy)
			sortMyNfts()
		case .retryAction:
			retryAction?()
		case .goBack:
			didSendEventClosure?(.close)
		}
	}
}

private extension DefaultMyNftsViewModel {
	func fetchAuthors() {
		isLoading.value = true

		let authorsID = Array(Set(items.value.map { $0.authorID }))
		// можно предположить что автор нужен один - такой case реализован в каталоге
		// добавлю при сливании
		dependencies.getAuthors.invoke(authorIDs: authorsID) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let authors):
				self.authors.value = authors
			case .failure(let error):
				self.retryAction = nil
				self.didSendEventClosure?(
					.showErrorAlert(error.description, withRetry: false)
				)
			}

			self.isLoading.value = false
		}
	}

	func likeItemWithID(_ nftID: String) {
		isLoading.value = true

		var likes = likes.value
		if likes.contains(nftID) {
			likes.removeAll { $0 == nftID }
		} else {
			likes.append(nftID)
		}

		dependencies.putLikes.invoke(likes: .init(nfts: likes)) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let likes):
				self.likes.value = likes.nfts
			case .failure(let error):
				self.retryAction = nil
				self.likes.value = self.likes.value
				self.didSendEventClosure?(
					.showErrorAlert(error.description, withRetry: false)
				)
			}

			self.isLoading.value = false
		}
	}

	func sortMyNfts() {
		let sortBy = dependencies.getSetSortOption.sortBy
		switch sortBy {
		case .name:
			items.value = items.value.sorted { $0.name < $1.name }
		case .price:
			items.value = items.value.sorted { $0.price > $1.price }
		case .rating:
			items.value = items.value.sorted { $0.rating > $1.rating }
		}
	}
}
