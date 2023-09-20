protocol OnboardingCoordinatorOutput: AnyObject {
	var finishFlow: (() -> Void)? { get set }
}

final class OnboardingCoordinator: BaseCoordinator, OnboardingCoordinatorOutput {
	private let container: OnboardingFlowDIContainer
	private let factory: OnboardingModuleFactory
	private let router: Router

	var finishFlow: (() -> Void)?

	init(router: Router, factory: OnboardingModuleFactory, container: OnboardingFlowDIContainer) {
		self.router = router
		self.factory = factory
		self.container = container
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
		let viewModel = container.makeOnboardingViewModel()

		let module = factory.makeOnboardingViewController(
			viewModel: viewModel,
			pagesData: viewModel.pagesData
		) { [weak viewModel] pageIndex in
			viewModel?.didUserDo(request: .showPage(pageIndex))
		}
		viewModel.didSendEventClosure = { [weak self] event in
			switch event {
			case .close:
				self?.router.dismissModule()
				self?.finishFlow?()
			}
		}
		router.setRootModule(module, hideBar: true)
	}
}
