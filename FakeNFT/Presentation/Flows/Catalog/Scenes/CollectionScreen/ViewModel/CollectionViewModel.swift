import Foundation

enum CollectionSection {
	case header(Author)
	case list([Nft])

	var rowCount: Int {
		switch self {
		case .header:
			return Appearance.headerCount
		case .list(let list):
			return list.count
		}
	}
}

private extension CollectionSection {
	enum Appearance {
		static let headerCount = 1
	}
}

enum CollectionEvents {
	case showErrorAlert(String, withRetry: Bool)
	case close
	case showAuthorSite(URL?)
}

enum CollectionRequest {
	case goBack
	case retryAction
}

protocol CollectionViewModelInput: AnyObject {
	var didSendEventClosure: ((CollectionEvents) -> Void)? { get set }

	func viewIsReady()
	func didUserDo(request: CollectionRequest)
}

protocol CollectionViewModelOutput: AnyObject {
	var dataSource: Observable<[CollectionSection]> { get }
	var order: Observable<[String]> { get }

	var isLoading: Observable<Bool> { get }
	var isTimeToCheckLikes: Observable<Bool> { get }
	var isTimeToRequestReview: Bool { get }

	var navBarData: NavBarInputData { get }

	var numberOfSection: Int { get }
	var cellModels: [ICellViewAnyModel.Type] { get }

	func numberOfItemInSection(_ index: Int) -> Int
	func cellModelInSectionAtIndex(section: Int, index: Int) -> ICellViewAnyModel
}

typealias CollectionViewModel = (
	CollectionViewModelInput &
	CollectionViewModelOutput
)

final class DefaultCollectionViewModel: CollectionViewModel {
	struct Dependencies {
		let collection: Collection
		let getAuthor: GetAuthorsUseCase
		let getNfts: GetNftsProfileUseCase
		let putLike: PutLikeByIDUseCase
		let getOrder: GetOrderUseCase
		let putOrder: PutOrderUseCase
		let likesIDsRepository: NftsIDsRepository
	}
	private let dependencies: Dependencies
	private var retryAction: (() -> Void)?

	private var author: Author?
	private var nfts: [Nft] = []
	private var errors: [String] = []
	private var likesForReview: Int

	// MARK: - INPUT
	var didSendEventClosure: ((CollectionEvents) -> Void)?

	// MARK: - OUTPUT
	var dataSource: Observable<[CollectionSection]> = Observable([])

	var order: Observable<[String]> = Observable([])
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

	var numberOfSection: Int { dataSource.value.count }
	var cellModels: [ICellViewAnyModel.Type] = [NftItemCellModel.self, CollectionHeaderCellModel.self]

	var navBarData: NavBarInputData {
		NavBarInputData(
			title: "",
			isGoBackButtonHidden: false,
			isSortButtonHidden: true,
			onTapGoBackButton: { [weak self] in self?.didUserDo(request: .goBack) },
			onTapSortButton: nil
		)
	}

	// MARK: - Inits

	init(dep: Dependencies) {
		dependencies = dep
		likesForReview = dep.likesIDsRepository.numberOfItems + Appearance.incrementToRequestReview

		self.bind(to: dep.likesIDsRepository)
	}
}

// MARK: - Bind

private extension DefaultCollectionViewModel {
	func bind(to repository: NftsIDsRepository) {
		repository.items.observe(on: self) { [weak self] _ in
			self?.isTimeToCheckLikes.value = true
		}
	}
}

// MARK: - OUTPUT

extension DefaultCollectionViewModel {
	func numberOfItemInSection(_ index: Int) -> Int {
		dataSource.value[index].rowCount
	}
	func cellModelInSectionAtIndex(section: Int, index: Int) -> ICellViewAnyModel {
		let section = dataSource.value[section]
		switch section {
		case .header(let author):
			return CollectionHeaderCellModel(
				imageURL: dependencies.collection.cover,
				title: dependencies.collection.name,
				author: author.name,
				description: dependencies.collection.description,
				onTapAuthor: { [weak self] in
					self?.didSendEventClosure?(.showAuthorSite(author.website))
				}
			)
		case .list(let list):
			let nft = list[index]
			return NftItemCellModel(
				avatarImageURL: nft.cover,
				isFavorite: dependencies.likesIDsRepository.hasItemByID(nft.id),
				rating: nft.rating,
				title: nft.name,
				price: nft.price,
				isInCart: order.value.contains(nft.id),
				onTapFavorite: { [weak self] in self?.likeItemWithID(nft.id) },
				onTapInCart: { [weak self] in self?.addToCartItemWithID(nft.id) }
			)
		}
	}
}

// MARK: - INPUT. View event methods

extension DefaultCollectionViewModel {
	func viewIsReady() {
		isLoading.value = true

		let authorID = dependencies.collection.authorID
		errors = []

		let group = DispatchGroup()

		fetchAuthor(group: group, authorID: authorID)
		fetchNfts(group: group, authorID: authorID)
		fetchOrder(group: group)

		group.notify(queue: .main) {
			self.makeDataSource()
			if self.dataSource.value.isEmpty {
				self.dataSource.value = []
			}
			if !self.errors.isEmpty {
				self.retryAction = { self.viewIsReady() }
				let message = self.errors.joined(separator: "\n")
				self.didSendEventClosure?(
					.showErrorAlert(message, withRetry: true)
				)
			}

			self.isLoading.value = false
		}
	}

	func didUserDo(request: CollectionRequest) {
		switch request {
		case .goBack:
			didSendEventClosure?(.close)
		case .retryAction:
			retryAction?()
		}
	}
}

private extension DefaultCollectionViewModel {
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

	func addToCartItemWithID(_ nftID: String) {
		isLoading.value = true

		var order = order.value
		if order.contains(nftID) {
			order.removeAll { $0 == nftID }
		} else {
			order.append(nftID)
		}

		dependencies.putOrder.invoke(order: .init(nfts: order)) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let order):
				self.order.value = order.nfts
			case .failure(let error):
				self.retryAction = nil
				self.order.value = self.order.value
				self.didSendEventClosure?(
					.showErrorAlert(error.description, withRetry: false)
				)
			}

			self.isLoading.value = false
		}
	}
}

private extension DefaultCollectionViewModel {
	func makeDataSource() {
		guard let author = author else { return }
		dataSource.value = [
			CollectionSection.header(
				.init(
					id: author.id,
					name: author.name,
					website: author.website
				)
			),
			CollectionSection.list(nfts)
		]
	}

	func fetchAuthor(group: DispatchGroup, authorID: String) {
		group.enter()
		dependencies.getAuthor.invoke(authorID: authorID) { [weak self] result in
			switch result {
			case .success(let author):
				self?.author = author
			case .failure(let error):
				self?.errors.append(error.description)
				print(error.localizedDescription)
			}
			group.leave()
		}
	}

	func fetchNfts(group: DispatchGroup, authorID: String) {
		group.enter()
		dependencies.getNfts.invoke(authorID: authorID) { [weak self] result in
			switch result {
			case .success(let nfts):
				self?.nfts = nfts
			case .failure(let error):
				self?.errors.append(error.description)
				print(error.localizedDescription)
			}
			group.leave()
		}
	}

	func fetchOrder(group: DispatchGroup) {
		group.enter()
		dependencies.getOrder.invoke { [weak self] result in
			switch result {
			case .success(let order):
				self?.order.value = order.nfts
			case .failure(let error):
				self?.errors.append(error.description)
				print(error.localizedDescription)
			}
			group.leave()
		}
	}
}

private extension DefaultCollectionViewModel {
	enum Appearance {
		static let incrementToRequestReview = 5
	}
}
