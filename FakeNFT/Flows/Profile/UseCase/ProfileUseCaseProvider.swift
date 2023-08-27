final class ProfileUseCaseProvider {
	// MARK: - Singleton
	static let instance = ProfileUseCaseProvider()
	private init() {}

	private let serviceProvider = ProfileServiceProvider()

	lazy var profileRepository: ProfileRepository = {
		serviceProvider.profileRepository
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

	lazy var getSetSortMyNtfsOption: SortMyNtfsOption = {
		GetSetSortMyNtfsOptionUseCase()
	}()
}
