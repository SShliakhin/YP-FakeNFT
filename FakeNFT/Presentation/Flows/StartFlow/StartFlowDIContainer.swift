import Foundation
protocol StartFlowDIContainer {
	func makeSplashViewModel() -> SplashViewModel
}

final class StartFlowDIContainerImp: StartFlowDIContainer {
	struct Dependencies {
		let getProfile: GetProfileUseCase
		let getOrder: GetOrderUseCase
		let getCollections: GetCollectionsUseCase
		let getAuthors: GetAuthorsUseCase
		let profileRepository: ProfileRepository
		let likesIDsRepository: NftsIDsRepository
		let myNftsIDsRepository: NftsIDsRepository
		let orderIDsRepository: NftsIDsRepository
		let collectionsRepository: CollectionsRepository
		let authorsRepository: AuthorsRepository
	}

	private let dependencies: Dependencies

	init(dependencies: Dependencies) {
		self.dependencies = dependencies
	}

	func makeSplashViewModel() -> SplashViewModel {
		let dep = DefaultSplashViewModel.Dependencies(
			getProfile: dependencies.getProfile,
			getOrder: dependencies.getOrder,
			getCollections: dependencies.getCollections,
			getAuthors: dependencies.getAuthors,
			profileRepository: dependencies.profileRepository,
			likesIDsRepository: dependencies.likesIDsRepository,
			myNftsIDsRepository: dependencies.myNftsIDsRepository,
			orderIDsRepository: dependencies.orderIDsRepository,
			collectionsRepository: dependencies.collectionsRepository,
			authorsRepository: dependencies.authorsRepository
		)

		return DefaultSplashViewModel(dep: dep)
	}
}
