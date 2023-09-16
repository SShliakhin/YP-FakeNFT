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
	case filterItemsBy(String)
	case list([String])
	case like
}

protocol MyNftsViewModelInput: AnyObject {
	var didSendEventClosure: ((MyNftsEvents) -> Void)? { get set }

	func viewIsReady()
	func didUserDo(request: MyNftsRequest)
}

protocol MyNftsViewModelOutput: AnyObject {
	var items: Observable<[Nft]> { get }

	var isLoading: Observable<Bool> { get }
	var isTimeToCheckLikes: Observable<Bool> { get }
	var isTimeToRequestReview: Bool { get }

	var numberOfItems: Int { get }
	var isEmpty: Bool { get }
	var cellModels: [ICellViewAnyModel.Type] { get }

	var emptyVCMessage: String { get }
	var placeholderSearchByTitle: String { get }
	var navBarData: NavBarInputData { get }

	func cellModelAtIndex(_ index: Int) -> ICellViewAnyModel
}

typealias MyNftsViewModel = (
	MyNftsViewModelInput &
	MyNftsViewModelOutput
)

final class DefaultMyNftsViewModel: MyNftsViewModel {
	struct Dependencies {
		let getMyNfts: GetNftsUseCase
		let getSetSortOption: SortMyNtfsOption
		let putLike: PutLikeByIDUseCase
		let authorsRepository: AuthorsRepository
		let likesIDsRepository: NftsIDsRepository
		let myNftsIDsRepository: NftsIDsRepository
	}
	private let dependencies: Dependencies
	private var retryAction: (() -> Void)?
	private var backendItems: [Nft] = [] {
		didSet { items.value = backendItems }
	}
	private var likesForReview: Int

	// MARK: - INPUT
	var didSendEventClosure: ((MyNftsEvents) -> Void)?

	// MARK: - OUTPUT
	var items: Observable<[Nft]> = Observable([])

	var isLoading: Observable<Bool> = Observable(false)
	var isTimeToCheckLikes: Observable<Bool> = Observable(false)
	var isTimeToRequestReview: Bool {
		let currentLikes = dependencies.likesIDsRepository.numberOfItems
		if currentLikes >= likesForReview {
			likesForReview += Appearance.incrementToRequestReview
			return true
		}
		return false
	}

	var numberOfItems: Int { items.value.count }
	var isEmpty: Bool { items.value.isEmpty }
	var cellModels: [ICellViewAnyModel.Type] = [MyNftsItemCellModel.self]

	var emptyVCMessage: String {
		if backendItems.isEmpty {
			return L10n.Profile.emptyVCMyNFTs
		} else {
			return L10n.SearchBar.noSearchResult
		}
	}
	var placeholderSearchByTitle: String = L10n.SearchBar.SearchByTitle
	var navBarData: NavBarInputData {
		NavBarInputData(
			title: isEmpty ? "" : L10n.Profile.titleVCMyNFTs,
			isGoBackButtonHidden: false,
			isSortButtonHidden: isEmpty,
			onTapGoBackButton: { [weak self] in
				self?.didUserDo(request: .goBack)
			},
			onTapSortButton: { [weak self] in
				self?.didUserDo(request: .selectSort)
			}
		)
	}

	// MARK: - Inits

	init(dep: Dependencies) {
		dependencies = dep
		likesForReview = dep.likesIDsRepository.numberOfItems + Appearance.incrementToRequestReview

		self.bind(to: dep.likesIDsRepository, request: .like)
		self.bind(to: dep.myNftsIDsRepository, request: .list([]))
	}
}

// MARK: - Bind

private extension DefaultMyNftsViewModel {
	func bind(to repository: NftsIDsRepository, request: MyNftsRequest) {
		repository.items.observe(on: self) { [weak self] ids in
			if case .like = request { self?.didUserDo(request: .like) }
			if case .list = request { self?.didUserDo(request: .list(ids)) }
		}
	}
}

// MARK: - OUTPUT

extension DefaultMyNftsViewModel {
	func cellModelAtIndex(_ index: Int) -> ICellViewAnyModel {
		let nft = items.value[index]
		let isFavorite = dependencies.likesIDsRepository.hasItemByID(nft.id)
		let author = dependencies.authorsRepository.getItemByID(nft.authorID)?.name ?? ""
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
		fetchNftsByIDs(dependencies.myNftsIDsRepository.items.value)
	}

	func didUserDo(request: MyNftsRequest) {
		switch request {
		case .selectSort:
			guard items.value.count > 1 else { return }
			didSendEventClosure?(.showSortAlert)
		case .selectSortBy(let sortBy):
			dependencies.getSetSortOption.setOption(sortBy)
			sortItems()
		case .retryAction:
			retryAction?()
		case .goBack:
			didSendEventClosure?(.close)
		case .filterItemsBy(let searchText):
			filterItemsBy(searchText)
		case .list(let ids):
			fetchNftsByIDs(ids)
		case .like:
			isTimeToCheckLikes.value = true
		}
	}
}

private extension DefaultMyNftsViewModel {
	func fetchNftsByIDs(_ myNfts: [String]) {
		isLoading.value = true

		dependencies.getMyNfts.invoke(nftIDs: myNfts) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let nfts):
				self.backendItems = nfts
			case .failure(let error):
				self.backendItems = []
				self.retryAction = { self.viewIsReady() }
				self.didSendEventClosure?(
					.showErrorAlert(error.description, withRetry: true)
				)
			}

			self.isLoading.value = false
			self.sortItems()
		}
	}

	func likeItemWithID(_ nftID: String) {
		isLoading.value = true

		dependencies.putLike.invoke(nftID) { [weak self] result in
			guard let self = self else { return }
			if case .failure(let error) = result {
				self.retryAction = nil
				self.didSendEventClosure?(
					.showErrorAlert(error.description, withRetry: false)
				)
			}

			self.isLoading.value = false
		}
	}

	func sortItems() {
		guard numberOfItems > 1 else { return }

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

	func filterItemsBy(_ text: String) {
		let text = text
			.trimmingCharacters(in: .whitespaces)
			.lowercased()
		if text.isEmpty {
			items.value = backendItems
		} else {
			items.value = backendItems.filter { $0.name.lowercased().contains(text) }
		}
		sortItems()
	}
}

private extension DefaultMyNftsViewModel {
	enum Appearance {
		static let incrementToRequestReview = 5
	}
}
