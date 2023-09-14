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

		viewModel.didSendEventClosuer = { [weak self, weak viewModel] event in
			switch event {
			case .showErrorAlert(let message, let withRetry):
				self?.presentErrorAlert(message: message, withRetry: withRetry) {
					viewModel?.didUserDo(request: .retryAction)
				}
			case .loadData:
				self?.router.dismissModule()
				self?.finishFlow?()
			}
		}
		router.setRootModule(module, hideBar: true)
	}

	func presentErrorAlert(
		message: String,
		withRetry: Bool = false,
		completion: (() -> Void)? = nil
	) {
		let module = factory.makeErrorAlertVC(
			message: message,
			completion: withRetry ? completion : nil
		)
		router.present(module)
	}
}
