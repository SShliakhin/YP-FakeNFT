protocol StartFlowDIContainer {
	func makeSplashViewModel() -> SplashViewModel
}

final class StartFlowDIContainerImp: StartFlowDIContainer {
	struct Dependencies {
		let getProfile: GetProfileUseCase
		let likesIDsRepository: NftsIDsRepository
		let myNftsIDsRepository: NftsIDsRepository
	}

	private let dependencies: Dependencies

	init(dependencies: Dependencies) {
		self.dependencies = dependencies
	}

	func makeSplashViewModel() -> SplashViewModel {
		let dep = DefaultSplashViewModel.Dependencies(
			getProfile: dependencies.getProfile,
			likesRepository: dependencies.likesIDsRepository,
			myNftsRepository: dependencies.myNftsIDsRepository
		)

		return DefaultSplashViewModel(dep: dep)
	}
}
