final class UseCaseProvider {
	struct Dependencies {
		let apiClient: APIClient
		let nftRepository: NftRepository
		let likesIDsRepository: NftsIDsRepository
		let orderIDsRepository: NftsIDsRepository
	}

	private let dependencies: Dependencies

	init(dependencies: Dependencies) {
		self.dependencies = dependencies
	}

	lazy var putLikeByID: PutLikeByIDUseCase = {
		PutLikeByIDUseCaseImp(
			apiClient: dependencies.apiClient,
			likesIDsRepository: dependencies.likesIDsRepository
		)
	}()

	lazy var searchNftsByName: SearchNftsByNameUseCase = {
		SearchNftsByNameUseCaseImp(apiClient: dependencies.apiClient)
	}()

	lazy var getCollections: GetCollectionsUseCase = {
		GetCollectionsUseCaseImp(apiClient: dependencies.apiClient)
	}()

	lazy var getProfile: GetProfileUseCase = {
		GetProfileUseCaseImp(apiClient: dependencies.apiClient)
	}()

	lazy var putProfile: PutProfileUseCase = {
		PutProfileUseCaseImp(apiClient: dependencies.apiClient)
	}()

	lazy var getNfts: GetNftsUseCase = {
		GetNftsUseCaseImp(
			apiClient: dependencies.apiClient,
			nftRepository: dependencies.nftRepository
		)
	}()

	lazy var getAuthors: GetAuthorsUseCase = {
		GetAuthorsUseCaseImp(apiClient: dependencies.apiClient)
	}()

	lazy var getOrder: GetOrderUseCase = {
		GetOrderUseCaseImp(apiClient: dependencies.apiClient)
	}()

	lazy var putNftToOrderByID: PutNftToOrderByIDUseCase = {
		PutNftToOrderByIDUseCaseImp(
			apiClient: dependencies.apiClient,
			orderIDsRepository: dependencies.orderIDsRepository
		)
	}()

	lazy var getSetSortMyNtfsOption: SortMyNtfsOption = {
		GetSetSortMyNtfsOptionUseCase()
	}()

	lazy var getSetSortCollectionsOption: SortCollectionsOption = {
		GetSetSortCollectionsOptionUseCase()
	}()
}
