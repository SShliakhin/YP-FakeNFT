import UIKit

final class CoordinatorFactoryImp: CoordinatorFactory {

	func makeOnboardingCoordinator(router: Router) -> Coordinator & OnboardingCoordinatorOutput {
		OnboardingCoordinator(router: router, factory: ModuleFactoryImp())
	}

	func makeAuthCoordinator(router: Router) -> Coordinator & AuthCoordinatorOutput {
		AuthCoordinator(router: router, factory: ModuleFactoryImp())
	}

	func makeTabbarCoordinator(container: MainFlowDIContainer) -> (configurator: Coordinator, toPresent: Presentable?) {
		let pages: [TabbarPage] = {
			[
				.profile,
				.catalog,
				.shoppingCart,
				.statistics
			].sorted(by: { $0.pageOrderNumber() < $1.pageOrderNumber() })
		}()
		let firstPage: TabbarPage = .shoppingCart

		let controller = TabBarController(pages: pages, firstPage: firstPage)
		let coordinator = TabbarCoordinator(
			pages: pages,
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