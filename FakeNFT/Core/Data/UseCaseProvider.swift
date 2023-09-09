final class UseCaseProvider {
	struct Dependencies {
		let apiClient: APIClient
		let profileRepository: ProfileRepository
	}

	private let dependencies: Dependencies

	init(dependencies: Dependencies) {
		self.dependencies = dependencies
	}

	lazy var searchNftsByName: SearchNftsByNameUseCase = {
		SearchNftsByNameUseCaseImp(apiClient: dependencies.apiClient)
	}()

	lazy var getCollections: GetCollectionsUseCase = {
		GetCollectionsUseCaseImp(apiClient: dependencies.apiClient)
	}()

	lazy var getProfile: GetProfileUseCase = {
		GetProfileUseCaseImp(
			apiClient: dependencies.apiClient,
			profileRepository: dependencies.profileRepository
		)
	}()

	lazy var putProfile: PutProfileUseCase = {
		PutProfileUseCaseImp(
			apiClient: dependencies.apiClient,
			profileRepository: dependencies.profileRepository
		)
	}()

	lazy var getNfts: GetNftsProfileUseCase = {
		GetNftsProfileUseCaseImp(
			apiClient: dependencies.apiClient,
			profileRepository: dependencies.profileRepository
		)
	}()

	lazy var getLikes: GetLikesProfileUseCase = {
		GetLikesProfileUseCaseImp(
			apiClient: dependencies.apiClient,
			profileRepository: dependencies.profileRepository
		)
	}()

	lazy var putLikes: PutLikesProfileUseCase = {
		PutLikesProfileUseCaseImp(
			apiClient: dependencies.apiClient,
			profileRepository: dependencies.profileRepository
		)
	}()

	lazy var getAuthors: GetAuthorsUseCase = {
		GetAuthorsUseCaseImp(
			apiClient: dependencies.apiClient,
			profileRepository: dependencies.profileRepository
		)
	}()

	lazy var getOrder: GetOrderUseCase = {
		GetOrderUseCaseImp(apiClient: dependencies.apiClient)
	}()

	lazy var putOrder: PutOrderUseCase = {
		PutOrderUseCaseImp(apiClient: dependencies.apiClient)
	}()

	lazy var getSetSortMyNtfsOption: SortMyNtfsOption = {
		GetSetSortMyNtfsOptionUseCase()
	}()

	lazy var getSetSortCollectionsOption: SortCollectionsOption = {
		GetSetSortCollectionsOptionUseCase()
	}()
}
