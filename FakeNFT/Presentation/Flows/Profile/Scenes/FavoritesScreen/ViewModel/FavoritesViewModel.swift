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
	var titleVC: String { get }

	func cellModelAtIndex(_ index: Int) -> ICellViewAnyModel
}

typealias FavoritesViewModel = (
	FavoritesViewModelInput &
	FavoritesViewModelOutput
)

final class DefaultFavoritesViewModel: FavoritesViewModel {
	struct Dependencies {
		let getNfts: GetNftsProfileUseCase
		let putLikes: PutLikesProfileUseCase
		let profileRepository: ProfileRepository
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
	var titleVC: String = L10n.Profile.titleVCFavorites

	// MARK: - Inits

	init(dep: Dependencies) {
		dependencies = dep

		self.bind(to: dep.profileRepository)
	}
}

// MARK: - Bind

private extension DefaultFavoritesViewModel {
	func bind(to repository: ProfileRepository) {
		repository.likes.observe(on: self) { [weak self] likes in
			self?.updateItemsByIDs(likes)
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
		updateItemsByIDs(dependencies.profileRepository.profileLikes)
	}

	private func updateItemsByIDs(_ likes: [String]) {
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
	func likeItemWithID(_ nftID: String) {
		var likes = items.value.map { $0.id }
		if likes.contains(nftID) {
			likes.removeAll { $0 == nftID }
		} else {
			return // такого не должно быть
		}

		isLoading.value = true

		dependencies.putLikes.invoke(likes: .init(nfts: likes)) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success:
				self.items.value.removeAll { $0.id == nftID }
			case .failure(let error):
				self.retryAction = nil
				self.didSendEventClosure?(
					.showErrorAlert(error.description, withRetry: false)
				)
			}

			self.isLoading.value = false
		}
	}
}
