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
	case like
	case order
}

protocol CollectionViewModelInput: AnyObject {
	var didSendEventClosure: ((CollectionEvents) -> Void)? { get set }

	func viewIsReady()
	func didUserDo(request: CollectionRequest)
}

protocol CollectionViewModelOutput: AnyObject {
	var dataSource: Observable<[CollectionSection]> { get }

	var isLoading: Observable<Bool> { get }
	var isTimeToCheckLikes: Observable<Bool> { get }
	var isTimeToCheckOrder: Observable<Bool> { get }
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

		let getNfts: GetNftsUseCase
		let putLike: PutLikeByIDUseCase
		let putNftToOrder: PutNftToOrderByIDUseCase

		let collectionsRepository: CollectionsRepository
		let authorsRepository: AuthorsRepository
		let likesIDsRepository: NftsIDsRepository
		let orderIDsRepository: NftsIDsRepository
	}
	private let dependencies: Dependencies
	private var retryAction: (() -> Void)?

	private var author: Author?
	private var nfts: [Nft] = []
	private var likesForReview: Int

	// MARK: - INPUT
	var didSendEventClosure: ((CollectionEvents) -> Void)?

	// MARK: - OUTPUT
	var dataSource: Observable<[CollectionSection]> = Observable([])

	var isLoading: Observable<Bool> = Observable(false)
	var isTimeToCheckLikes: Observable<Bool> = Observable(false)
	var isTimeToCheckOrder: Observable<Bool> = Observable(false)
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

		self.bind(to: dep.likesIDsRepository, request: .like)
		self.bind(to: dep.orderIDsRepository, request: .order)
	}
}

// MARK: - Bind

private extension DefaultCollectionViewModel {
	func bind(to repository: NftsIDsRepository, request: CollectionRequest) {
		repository.items.observe(on: self) { [weak self] _ in
			if case .like = request { self?.didUserDo(request: .like) }
			if case .order = request { self?.didUserDo(request: .order) }
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
				isInCart: dependencies.orderIDsRepository.hasItemByID(nft.id),
				onTapFavorite: { [weak self] in self?.likeItemWithID(nft.id) },
				onTapInCart: { [weak self] in self?.addToCartItemWithID(nft.id) }
			)
		}
	}
}

// MARK: - INPUT. View event methods

extension DefaultCollectionViewModel {
	func viewIsReady() {
		let authorID = dependencies.collection.authorID
		author = dependencies.authorsRepository.getItemByID(authorID)

		isLoading.value = true

		dependencies.getNfts.invoke(authorID: authorID) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let nfts):
				self.nfts = nfts
				self.makeDataSource()
			case .failure(let error):
				self.retryAction = { self.viewIsReady() }
				self.didSendEventClosure?(.showErrorAlert(error.description, withRetry: true))
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
		case .like:
			isTimeToCheckLikes.value = true
		case .order:
			isTimeToCheckOrder.value = true
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

		dependencies.putNftToOrder.invoke(nftID) { [weak self] result in
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
}

private extension DefaultCollectionViewModel {
	enum Appearance {
		static let incrementToRequestReview = 5
	}
}
