enum FavoritesEvents {
	case showErrorAlert(String, withRetry: Bool)
	case close
}

enum FavoritesRequest {
	case retryAction
	case goBack
}

protocol FavoritesViewModelInput: AnyObject {
	var didSendEventClosure: ((FavoritesEvents) -> Void)? { get set }

	func viewIsReady()
	func didUserDo(request: FavoritesRequest)
}

protocol FavoritesViewModelOutput: AnyObject {
	var items: Observable<[Nft]> { get }

	var isLoading: Observable<Bool> { get }

	var numberOfItems: Int { get }
	var isEmpty: Bool { get }
	var cellModels: [ICellViewAnyModel.Type] { get }

	var emptyVCMessage: String { get }
	var navBarData: NavBarInputData { get }

	func cellModelAtIndex(_ index: Int) -> ICellViewAnyModel
}

typealias FavoritesViewModel = (
	FavoritesViewModelInput &
	FavoritesViewModelOutput
)

final class DefaultFavoritesViewModel: FavoritesViewModel {
	struct Dependencies {
		let getNfts: GetNftsProfileUseCase
		let putLike: PutLikeByIDUseCase
		let likesIDsRepository: NftsIDsRepository
	}
	private let dependencies: Dependencies
	private var retryAction: (() -> Void)?

	// MARK: - INPUT
	var didSendEventClosure: ((FavoritesEvents) -> Void)?

	// MARK: - OUTPUT
	var items: Observable<[Nft]> = Observable([])

	var isLoading: Observable<Bool> = Observable(false)

	var numberOfItems: Int { items.value.count }
	var isEmpty: Bool { items.value.isEmpty }
	var cellModels: [ICellViewAnyModel.Type] = [FavoritesItemCellModel.self]

	var emptyVCMessage: String = L10n.Profile.emptyVCFavorites
	var navBarData: NavBarInputData {
		NavBarInputData(
			title: isEmpty ? "" : L10n.Profile.titleVCFavorites,
			isGoBackButtonHidden: false,
			isSortButtonHidden: true,
			onTapGoBackButton: { [weak self] in self?.didUserDo(request: .goBack) },
			onTapSortButton: nil
		)
	}

	// MARK: - Inits

	init(dep: Dependencies) {
		dependencies = dep

		self.bind(to: dep.likesIDsRepository)
	}
}

// MARK: - Bind

private extension DefaultFavoritesViewModel {
	func bind(to repository: NftsIDsRepository) {
		repository.items.observe(on: self) { [weak self] ids in
			self?.fetchNftsByIDs(ids)
		}
	}
}

// MARK: - OUTPUT

extension DefaultFavoritesViewModel {
	func cellModelAtIndex(_ index: Int) -> ICellViewAnyModel {
		let nft = items.value[index]
		let isFavorite = true
		let price = Theme.getPriceStringFromDouble(nft.price)

		return FavoritesItemCellModel(
			avatarImageURL: nft.cover,
			isFavorite: isFavorite,
			title: nft.name,
			rating: nft.rating,
			price: price,
			onTapFavorite: { [weak self] in self?.likeItemWithID(nft.id) }
		)
	}
}

// MARK: - INPUT. View event methods

extension DefaultFavoritesViewModel {
	func viewIsReady() {
		fetchNftsByIDs(dependencies.likesIDsRepository.items.value)
	}

	func didUserDo(request: FavoritesRequest) {
		switch request {
		case .retryAction:
			retryAction?()
		case .goBack:
			didSendEventClosure?(.close)
		}
	}
}

private extension DefaultFavoritesViewModel {
	func fetchNftsByIDs(_ likes: [String]) {
		if !isEmpty {
			let filteredNfts = items.value.filter { likes.contains($0.id) }
			if filteredNfts.count == likes.count {
				items.value = filteredNfts
				return
			}
		}

		isLoading.value = true

		dependencies.getNfts.invoke(nftIDs: likes) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let likes):
				self.items.value = likes
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
}
