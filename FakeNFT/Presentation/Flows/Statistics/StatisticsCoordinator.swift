final class StatisticsCoordinator: BaseCoordinator {
	private let factory: StatisticsModuleFactory
	private let router: Router

	init(router: Router, factory: StatisticsModuleFactory) {
		self.router = router
		self.factory = factory
	}

	override func start() {
		showStatisticsModule()
	}

	deinit {
		print("StatisticsCoordinator deinit")
	}
}

// MARK: - show Modules
private extension StatisticsCoordinator {
	func showStatisticsModule() {
		let module = factory.makeStatisticsViewController(viewModel: DefaultStatisticsViewModel())
		router.setRootModule(module)
	}
}

protocol StatisticsViewModel {}
final class DefaultStatisticsViewModel: StatisticsViewModel {}
