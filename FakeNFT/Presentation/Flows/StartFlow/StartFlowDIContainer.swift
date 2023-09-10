protocol StartFlowDIContainer {
	func makeSplashViewModel() -> SplashViewModel
}

final class StartFlowDIContainerImp: StartFlowDIContainer {
	struct Dependencies {}

	private let dependencies: Dependencies

	init(dependencies: Dependencies) {
		self.dependencies = dependencies
	}

	func makeSplashViewModel() -> SplashViewModel {
		SplashViewModelImp()
	}
}
