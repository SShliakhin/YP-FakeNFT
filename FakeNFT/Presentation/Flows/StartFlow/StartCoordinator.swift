protocol StartCoordinatorOutput: AnyObject {
	var finishFlow: (() -> Void)? { get set }
}

final class StartCoordinator: BaseCoordinator, StartCoordinatorOutput {
	private let container: StartFlowDIContainer
	private let factory: StartModuleFactory
	private let router: Router

	var finishFlow: (() -> Void)?

	init(router: Router, factory: StartModuleFactory, container: StartFlowDIContainer) {
		self.router = router
		self.factory = factory
		self.container = container
	}

	override func start() {
		showSplashModule()
	}

	deinit {
		print("StartCoordinator deinit")
	}
}

// MARK: - show Modules
private extension StartCoordinator {
	func showSplashModule() {
		let viewModel = container.makeSplashViewModel()
		let module = factory.makeSplashViewController(viewModel: viewModel)

		viewModel.didSendEventClouser = { [weak self] event in
			switch event {
			case .loadData:
				self?.router.dismissModule()
				self?.finishFlow?()
			case .error:
				break
			}
		}
		router.setRootModule(module, hideBar: true)
	}
}
