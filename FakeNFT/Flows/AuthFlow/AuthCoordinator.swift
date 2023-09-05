protocol AuthCoordinatorOutput: AnyObject {
	var finishFlow: (() -> Void)? { get set }
}

final class AuthCoordinator: BaseCoordinator, AuthCoordinatorOutput {
	private let factory: AuthModuleFactory
	private let router: Router

	var finishFlow: (() -> Void)?

	init(router: Router, factory: AuthModuleFactory) {
		self.router = router
		self.factory = factory
	}

	override func start() {
		showAuthModule()
	}

	deinit {
		print("AuthCoordinator deinit")
	}
}

// MARK: - show Modules
private extension AuthCoordinator {
	func showAuthModule() {
		let viewModel = DefaultAuthViewModel()
		let module = factory.makeAuthViewController(viewModel: viewModel)
		viewModel.didSendEventClosure = { [weak self] event in
			switch event {
			case .close:
				self?.finishFlow?()
			}
		}
		router.setRootModule(module)
	}
}
