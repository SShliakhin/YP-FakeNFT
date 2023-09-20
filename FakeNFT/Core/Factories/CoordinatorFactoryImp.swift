import UIKit

final class CoordinatorFactoryImp: CoordinatorFactory {
	func makeStartCoordinator(router: Router, container: StartFlowDIContainer) -> Coordinator & StartCoordinatorOutput {
		StartCoordinator(
			router: router,
			factory: ModuleFactoryImp(),
			container: container
		)
	}

	func makeOnboardingCoordinator(
		router: Router,
		container: OnboardingFlowDIContainer
	) -> Coordinator & OnboardingCoordinatorOutput {
		OnboardingCoordinator(
			router: router,
			factory: ModuleFactoryImp(),
			container: container
		)
	}

	func makeAuthCoordinator(router: Router) -> Coordinator & AuthCoordinatorOutput {
		AuthCoordinator(router: router, factory: ModuleFactoryImp())
	}

	func makeTabbarCoordinator(container: MainDIContainer) -> (configurator: Coordinator, toPresent: Presentable?) {
		let controller = TabBarController()
		let coordinator = TabbarCoordinator(
			tabbarController: controller,
			coordinatorFactory: CoordinatorFactoryImp(),
			container: container
		)
		return (coordinator, controller)
	}

	func makeProfileCoordinator(navController: UINavigationController, container: ProfileFlowDIContainer) -> Coordinator {
		ProfileCoordinator(
			router: router(navController),
			factory: ModuleFactoryImp(),
			container: container
		)
	}

	func makeCatalogCoordinator(navController: UINavigationController, container: CatalogFlowDIContainer) -> Coordinator {
		CatalogCoordinator(
			router: router(navController),
			factory: ModuleFactoryImp(),
			container: container
		)
	}

	func makeShoppingCartCoordinator(navController: UINavigationController) -> Coordinator {
		ShoppingCartCoordinator(
			router: router(navController),
			factory: ModuleFactoryImp()
		)
	}

	func makeStatisticsCoordinator(navController: UINavigationController) -> Coordinator {
		StatisticsCoordinator(
			router: router(navController),
			factory: ModuleFactoryImp()
		)
	}

	private func router(_ navController: UINavigationController) -> Router {
		return RouterImp(rootController: navController)
	}
}
