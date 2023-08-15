final class CatalogUseCaseProvider {
	// MARK: - Singleton
	static let instance = CatalogUseCaseProvider()
	private init() {}

	private let serviceProvider = CatalogServiceProvider()

	lazy var getCollections: GetCollectionsUseCase = {
		GetCollectionsUseCaseImp(apiClient: serviceProvider.apiClient)
	}()

	lazy var getCollection: GetCollectionUseCase = {
		.init(apiClient: serviceProvider.apiClient)
	}()

	lazy var getNfts: GetNftsUseCase = {
		GetNftsUseCaseImp(apiClient: serviceProvider.apiClient)
	}()

	lazy var getAuthor: GetAuthorUseCase = {
		GetAuthorUseCaseImp(apiClient: serviceProvider.apiClient)
	}()

	lazy var getLikes: GetLikesUseCase = {
		GetLikesUseCaseImp(apiClient: serviceProvider.apiClient)
	}()

	lazy var putLikes: PutLikesUseCase = {
		PutLikesUseCaseImp(apiClient: serviceProvider.apiClient)
	}()

	lazy var getOrder: GetOrderUseCase = {
		GetOrderUseCaseImp(apiClient: serviceProvider.apiClient)
	}()

	lazy var putOrder: PutOrderUseCase = {
		PutOrderUseCaseImp(apiClient: serviceProvider.apiClient)
	}()

	lazy var getSetSortCollectionsOption: SortCollectionsOption = {
		GetSetSortCollectionsOptionUseCase()
	}()
}
