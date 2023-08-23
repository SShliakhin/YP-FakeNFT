final class ProfileUseCaseProvider {
	// MARK: - Singleton
	static let instance = ProfileUseCaseProvider()
	private init() {}

	private let serviceProvider = ProfileServiceProvider()

	lazy var getProfile: GetProfileUseCase = {
		GetProfileUseCaseImp(apiClient: serviceProvider.apiClient)
	}()

	lazy var putProfile: PutProfileUseCase = {
		PutProfileUseCaseImp(apiClient: serviceProvider.apiClient)
	}()

	lazy var getNfts: GetNftsProfileUseCase = {
		GetNftsProfileUseCaseImp(apiClient: serviceProvider.apiClient)
	}()

	lazy var getLikes: GetLikesProfileUseCase = {
		GetLikesProfileUseCaseImp(apiClient: serviceProvider.apiClient)
	}()

	lazy var putLikes: PutLikesProfileUseCase = {
		PutLikesProfileUseCaseImp(apiClient: serviceProvider.apiClient)
	}()

	lazy var getAuthors: GetAuthorsUseCase = {
		GetAuthorsUseCaseImp(apiClient: serviceProvider.apiClient)
	}()

	lazy var getSetSortMyNtfsOption: SortMyNtfsOption = {
		GetSetSortMyNtfsOptionUseCase()
	}()
}
