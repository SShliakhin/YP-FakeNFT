import UIKit

protocol AppFactory {
	func makeKeyWindowWithCoordinator(scene: UIWindowScene) -> (UIWindow, Coordinator)
}

protocol StartDIContainer {
	func makeStartFlowDIContainer() -> StartFlowDIContainer
}

protocol MainDIContainer {
	func makeProfileFlowDIContainer() -> ProfileFlowDIContainer
	func makeCatalogFlowDIContainer() -> CatalogFlowDIContainer
}

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

// MARK: - StartDIContainer

extension AppDIContainer: StartDIContainer {
	func makeStartFlowDIContainer() -> StartFlowDIContainer {
		let dep = StartFlowDIContainerImp.Dependencies(
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

		return StartFlowDIContainerImp(dependencies: dep)
	}
}

// MARK: - MainDIContainer

extension AppDIContainer: MainDIContainer {
	func makeProfileFlowDIContainer() -> ProfileFlowDIContainer {
		let dep = ProfileFlowDIContainerImp.Dependencies(
			getProfile: useCases.getProfile,
			putProfile: useCases.putProfile,
			getMyNfts: useCases.getNfts,
			getSetSortOption: useCases.getSetSortMyNtfsOption,
			putLike: useCases.putLikeByID,
			searchNftsByName: useCases.searchNftsByName,

			profileRepository: profileRepository,
			authorsRepository: authorsRepository,
			likesIDsRepository: likesIDsRepository,
			myNftsIDsRepository: myNftsIDsRepository
		)

		return ProfileFlowDIContainerImp(dependencies: dep)
	}

	func makeCatalogFlowDIContainer() -> CatalogFlowDIContainer {
		let dep = CatalogFlowDIContainerImp.Dependencies(
			getSetSortOption: useCases.getSetSortCollectionsOption,
			getNfts: useCases.getNfts,
			putLike: useCases.putLikeByID,
			putNftToOrder: useCases.putNftToOrderByID,

			collectionsRepository: collectionsRepository,
			authorsRepository: authorsRepository,
			likesIDsRepository: likesIDsRepository,
			orderIDsRepository: orderIDsRepository
		)

		return CatalogFlowDIContainerImp(dependencies: dep)
	}
}
