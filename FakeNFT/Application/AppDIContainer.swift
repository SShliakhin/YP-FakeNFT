import UIKit

protocol AppFactory {
	func makeKeyWindowWithCoordinator(scene: UIWindowScene) -> (UIWindow, Coordinator)
}

protocol MainFlowDIContainer {
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
	lazy var profileRepository: ProfileRepository = {
		ProfileRepositoryImp()
	}()

	// MARK: - UseCases
	lazy var useCases: UseCaseProvider = {
		let dep = UseCaseProvider.Dependencies(
			apiClient: apiClient,
			profileRepository: profileRepository
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

// MARK: - MainDIContainer

extension AppDIContainer: MainFlowDIContainer {
	// MARK: - DIContainers of flows
	func makeProfileFlowDIContainer() -> ProfileFlowDIContainer {
		let dep = ProfileFlowDIContainerImp.Dependencies(
			getProfile: useCases.getProfile,
			putProfile: useCases.putProfile,
			getMyNfts: useCases.getNfts,
			getSetSortOption: useCases.getSetSortMyNtfsOption,
			putLikes: useCases.putLikes,
			getAuthors: useCases.getAuthors,
			profileRepository: profileRepository
		)
		return ProfileFlowDIContainerImp(dependencies: dep)
	}

	func makeCatalogFlowDIContainer() -> CatalogFlowDIContainer {
		let dep = CatalogFlowDIContainerImp.Dependencies(
			getCollections: useCases.getCollections,
			getSetSortOption: useCases.getSetSortCollectionsOption,
			getAuthor: useCases.getAuthors,
			getNfts: useCases.getNfts,
			getLikes: useCases.getLikes,
			putLikes: useCases.putLikes,
			getOrder: useCases.getOrder,
			putOrder: useCases.putOrder
		)
		return CatalogFlowDIContainerImp(dependencies: dep)
	}
}
