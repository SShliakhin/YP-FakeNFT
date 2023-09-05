import UIKit

final class TabbarCoordinator: BaseCoordinator {
	private let pages: [TabbarPage]
	private let tabbarController: UITabBarController
	private let coordinatorFactory: CoordinatorFactory
	private let container: MainFlowDIContainer

	init(
		pages: [TabbarPage],
		tabbarController: UITabBarController,
		coordinatorFactory: CoordinatorFactory,
		container: MainFlowDIContainer
	) {
		self.pages = pages
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

// MARK: - run Flows
private extension TabbarCoordinator {
	func runFlowByIndex(_ index: Int, on controller: UINavigationController) {
		let coordinator: Coordinator
		switch pages[index] {
		case .profile:
			coordinator = coordinatorFactory
				.makeProfileCoordinator(
					navController: controller,
					container: container.makeProfileFlowDIContainer()
				)
		case .catalog:
			coordinator = coordinatorFactory
				.makeCatalogCoordinator(
					navController: controller,
					container: container.makeCatalogFlowDIContainer()
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
