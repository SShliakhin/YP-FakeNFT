protocol OnboardingCoordinatorOutput: AnyObject {
	var finishFlow: (() -> Void)? { get set }
}

final class OnboardingCoordinator: BaseCoordinator, OnboardingCoordinatorOutput {
	private let factory: OnboardingModuleFactory
	private let router: Router

	var finishFlow: (() -> Void)?

	init(router: Router, factory: OnboardingModuleFactory) {
		self.router = router
		self.factory = factory
	}

	override func start() {
		showOnboardingModule()
	}

	deinit {
		print("OnboardingCoordinator deinit")
	}
}

// MARK: - show Modules
private extension OnboardingCoordinator {
	func showOnboardingModule() {
		let viewModel = DefaultOnboardingViewModel()
		let module = factory.makeOnboardingViewController(viewModel: viewModel)
		viewModel.didSendEventClosure = { [weak self] event in
			switch event {
			case .close:
				self?.router.dismissModule()
				self?.finishFlow?()
			}
		}
		router.setRootModule(module)
	}
}
