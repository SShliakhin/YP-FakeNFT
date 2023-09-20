import UIKit

final class TabbarCoordinator: BaseCoordinator {
	private let tabbarController: UITabBarController
	private let coordinatorFactory: CoordinatorFactory
	private let container: MainDIContainer

	private let pages: [TabbarPage] = TabbarPage.allTabbarPages

	init(
		tabbarController: UITabBarController,
		coordinatorFactory: CoordinatorFactory,
		container: MainDIContainer
	) {
		self.tabbarController = tabbarController
		self.coordinatorFactory = coordinatorFactory
		self.container = container
	}

	override func start() {
		tabbarController.viewControllers?.enumerated().forEach { item in
			guard let controller = item.element as? UINavigationController else { return }
			runFlowByIndex(item.offset, on: controller)
		}
	}

	deinit {
		print("TabbarCoordinator deinit")
	}
}

// MARK: - run Flows -
private extension TabbarCoordinator {
	func runFlowByIndex(_ index: Int, on controller: UINavigationController) {
		let coordinator: Coordinator
		switch pages[index] {
		case .profile:
			coordinator = coordinatorFactory
				.makeProfileCoordinator(
					navController: controller,
					container: container
				)
		case .catalog:
			coordinator = coordinatorFactory
				.makeCatalogCoordinator(
					navController: controller,
					container: container
				)
		case .shoppingCart:
			coordinator = coordinatorFactory
				.makeShoppingCartCoordinator(navController: controller)
		case .statistics:
			coordinator = coordinatorFactory
				.makeStatisticsCoordinator(navController: controller)
		}
		addDependency(coordinator)
		coordinator.start()
	}
}
