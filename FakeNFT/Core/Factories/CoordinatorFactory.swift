import UIKit

protocol CoordinatorFactory {
	func makeStartCoordinator(router: Router, container: StartFlowDIContainer) -> Coordinator & StartCoordinatorOutput
	func makeOnboardingCoordinator(
		router: Router,
		container: OnboardingFlowDIContainer
	) -> Coordinator & OnboardingCoordinatorOutput
	func makeAuthCoordinator(router: Router) -> Coordinator & AuthCoordinatorOutput

	func makeTabbarCoordinator(container: MainDIContainer) -> (configurator: Coordinator, toPresent: Presentable?)

	func makeProfileCoordinator(navController: UINavigationController, container: ProfileFlowDIContainer) -> Coordinator
	func makeCatalogCoordinator(navController: UINavigationController, container: CatalogFlowDIContainer) -> Coordinator
	func makeShoppingCartCoordinator(navController: UINavigationController) -> Coordinator
	func makeStatisticsCoordinator(navController: UINavigationController) -> Coordinator
}
