protocol StartFlowDIContainer {
	func makeSplashViewModel() -> SplashViewModel
}

final class StartFlowDIContainerImp: StartFlowDIContainer {
	struct Dependencies {
		let getProfile: GetProfileUseCase
		let likesRepository: NftsIDsRepository
		let myNftsRepository: NftsIDsRepository
	}

	private let dependencies: Dependencies

	init(dependencies: Dependencies) {
		self.dependencies = dependencies
	}

	func makeSplashViewModel() -> SplashViewModel {
		let dep = DefaultSplashViewModel.Dependencies(
			getProfile: dependencies.getProfile,
			likesRepository: dependencies.likesRepository,
			myNftsRepository: dependencies.myNftsRepository
		)

		return DefaultSplashViewModel(dep: dep)
	}
}
