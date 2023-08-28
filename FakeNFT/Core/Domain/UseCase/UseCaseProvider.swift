final class UseCaseProvider {
	// MARK: - Singleton
	static let instance = UseCaseProvider()
	private init() {}

	private let serviceProvider = ServiceProvider()

	lazy var profileRepository: ProfileRepository = {
		serviceProvider.profileRepository
	}()

	lazy var getCollections: GetCollectionsUseCase = {
		GetCollectionsUseCaseImp(apiClient: serviceProvider.apiClient)
	}()

	lazy var getProfile: GetProfileUseCase = {
		GetProfileUseCaseImp(
			apiClient: serviceProvider.apiClient,
			profileRepository: profileRepository
		)
	}()

	lazy var putProfile: PutProfileUseCase = {
		PutProfileUseCaseImp(
			apiClient: serviceProvider.apiClient,
			profileRepository: profileRepository
		)
	}()

	lazy var getNfts: GetNftsProfileUseCase = {
		GetNftsProfileUseCaseImp(
			apiClient: serviceProvider.apiClient,
			profileRepository: profileRepository
		)
	}()

	lazy var getLikes: GetLikesProfileUseCase = {
		GetLikesProfileUseCaseImp(
			apiClient: serviceProvider.apiClient,
			profileRepository: profileRepository
		)
	}()

	lazy var putLikes: PutLikesProfileUseCase = {
		PutLikesProfileUseCaseImp(
			apiClient: serviceProvider.apiClient,
			profileRepository: profileRepository
		)
	}()

	lazy var getAuthors: GetAuthorsUseCase = {
		GetAuthorsUseCaseImp(
			apiClient: serviceProvider.apiClient,
			profileRepository: profileRepository
		)
	}()

	lazy var getOrder: GetOrderUseCase = {
		GetOrderUseCaseImp(apiClient: serviceProvider.apiClient)
	}()

	lazy var putOrder: PutOrderUseCase = {
		PutOrderUseCaseImp(apiClient: serviceProvider.apiClient)
	}()

	lazy var getSetSortMyNtfsOption: SortMyNtfsOption = {
		GetSetSortMyNtfsOptionUseCase()
	}()

	lazy var getSetSortCollectionsOption: SortCollectionsOption = {
		GetSetSortCollectionsOptionUseCase()
	}()
}
