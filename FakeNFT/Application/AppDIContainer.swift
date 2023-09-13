import UIKit

protocol AppFactory {
	func makeKeyWindowWithCoordinator(scene: UIWindowScene) -> (UIWindow, Coordinator)
}

protocol StartFlowDIContainer {
	func makeSplashViewModel() -> SplashViewModel
}

protocol ProfileFlowDIContainer {
	func makeProfileViewModel() -> ProfileViewModel
	func makeMyNftsViewModel() -> MyNftsViewModel
	func makeFavoritesViewModel() -> FavoritesViewModel
	func makeSearchNftsViewModel() -> MyNftsViewModel
}

protocol CatalogFlowDIContainer {
	func makeCatalogViewModel() -> CatalogViewModel
	func makeCollectionViewModel(collection: Collection) -> CollectionViewModel
}

protocol SpoppingCartFlowDIContainer {}
protocol StatisticsFlowDIContainer {}

typealias MainDIContainer = (
	ProfileFlowDIContainer &
	CatalogFlowDIContainer &
	SpoppingCartFlowDIContainer &
	StatisticsFlowDIContainer
)

final class AppDIContainer {
	private let session = URLSession(configuration: .default)

	// MARK: - Network
	lazy var apiClient: APIClient = {
		APIClient(session: session)
	}()

	// MARK: - Repository
	let profileRepository: ProfileRepository = ProfileRepositoryImp()
	let nftRepository: NftRepository = NftRepositoryImp()
	let likesIDsRepository: NftsIDsRepository = LikesIDsRepository()
	let myNftsIDsRepository: NftsIDsRepository = MyNftsIDsRepository()
	let orderIDsRepository: NftsIDsRepository = OrderIDsRepository()
	let collectionsRepository: CollectionsRepository = CollectionsRepositoryImp()
	let authorsRepository: AuthorsRepository = AuthorsRepositoryImp()

	// MARK: - UseCases
	lazy var useCases: UseCaseProvider = {
		let dep = UseCaseProvider.Dependencies(
			apiClient: apiClient,
			nftRepository: nftRepository,
			likesIDsRepository: likesIDsRepository,
			orderIDsRepository: orderIDsRepository
		)
		return UseCaseProvider(dependencies: dep)
	}()
}

// MARK: - AppFactory

extension AppDIContainer: AppFactory {
	func makeKeyWindowWithCoordinator(scene: UIWindowScene) -> (UIWindow, Coordinator) {
		let window = UIWindow(windowScene: scene)
		window.makeKeyAndVisible()

		let navigationController = UINavigationController()

		let router = RouterImp(rootController: navigationController)
		let coordinator = makeApplicationCoordinator(router: router)

		window.rootViewController = navigationController
		return (window, coordinator)
	}

	private func makeApplicationCoordinator(router: Router) -> Coordinator {
		AppCoordinator(
			coordinatorFactory: CoordinatorFactoryImp(),
			router: router,
			appContext: AppContextImp(),
			container: self
		)
	}
}

// MARK: - StartFlowDIContainer

extension AppDIContainer: StartFlowDIContainer {
	func makeSplashViewModel() -> SplashViewModel {
		let dep = DefaultSplashViewModel.Dependencies(
			getProfile: useCases.getProfile,
			getOrder: useCases.getOrder,
			getCollections: useCases.getCollections,
			getAuthors: useCases.getAuthors,

			profileRepository: profileRepository,
			likesIDsRepository: likesIDsRepository,
			myNftsIDsRepository: myNftsIDsRepository,
			orderIDsRepository: orderIDsRepository,
			collectionsRepository: collectionsRepository,
			authorsRepository: authorsRepository
		)

		return DefaultSplashViewModel(dep: dep)
	}
}

// MARK: - ProfileFlowDIContainer

extension AppDIContainer: ProfileFlowDIContainer {
	func makeProfileViewModel() -> ProfileViewModel {
		let dep = DefaultProfileViewModel.Dependencies(
			getProfile: useCases.getProfile,
			putProfile: useCases.putProfile,
			profileRepository: profileRepository,
			likesIDsRepository: likesIDsRepository,
			myNftsIDsRepository: myNftsIDsRepository
		)

		return DefaultProfileViewModel(dep: dep)
	}

	func makeMyNftsViewModel() -> MyNftsViewModel {
		let dep = DefaultMyNftsViewModel.Dependencies(
			getMyNfts: useCases.getNfts,
			getSetSortOption: useCases.getSetSortMyNtfsOption,
			putLike: useCases.putLikeByID,
			authorsRepository: authorsRepository,
			likesIDsRepository: likesIDsRepository,
			myNftsIDsRepository: myNftsIDsRepository
		)

		return DefaultMyNftsViewModel(dep: dep)
	}

	func makeFavoritesViewModel() -> FavoritesViewModel {
		let dep = DefaultFavoritesViewModel.Dependencies(
			getNfts: useCases.getNfts,
			putLike: useCases.putLikeByID,
			likesIDsRepository: likesIDsRepository
		)

		return DefaultFavoritesViewModel(dep: dep)
	}

	func makeSearchNftsViewModel() -> MyNftsViewModel {
		let dep = SearchNftsViewModel.Dependencies(
			searchNftsByName: useCases.searchNftsByName,
			getSetSortOption: useCases.getSetSortMyNtfsOption,
			putLike: useCases.putLikeByID,
			authorsRepository: authorsRepository,
			likesIDsRepository: likesIDsRepository
		)

		return SearchNftsViewModel(dep: dep)
	}
}

// MARK: - CatalogFlowDIContainer

extension AppDIContainer: CatalogFlowDIContainer {
	func makeCatalogViewModel() -> CatalogViewModel {
		let dep = DefaultCatalogViewModel.Dependencies(
			getSetSortOption: useCases.getSetSortCollectionsOption,
			collectionsRepository: collectionsRepository
		)

		return DefaultCatalogViewModel(dep: dep)
	}

	func makeCollectionViewModel(collection: Collection) -> CollectionViewModel {
		let dep = DefaultCollectionViewModel.Dependencies(
			collection: collection,
			getNfts: useCases.getNfts,
			putLike: useCases.putLikeByID,
			putNftToOrder: useCases.putNftToOrderByID,

			collectionsRepository: collectionsRepository,
			authorsRepository: authorsRepository,
			likesIDsRepository: likesIDsRepository,
			orderIDsRepository: orderIDsRepository
		)

		return DefaultCollectionViewModel(dep: dep)
	}
}

// MARK: - SpoppingCartFlowDIContainer

extension AppDIContainer: SpoppingCartFlowDIContainer {}

// MARK: - StatisticsFlowDIContainer

extension AppDIContainer: StatisticsFlowDIContainer {}
