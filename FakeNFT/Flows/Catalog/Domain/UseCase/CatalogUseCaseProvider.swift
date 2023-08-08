final class CatalogUseCaseProvider {
	// MARK: - Singleton
	static let instance = CatalogUseCaseProvider()
	private init() {}

	private let serviceProvider = CatalogServiceProvider()

	lazy var getCollections: GetCollectionsUseCase = {
		.init(apiClient: serviceProvider.apiClient)
	}()

	lazy var getCollection: GetCollectionUseCase = {
		.init(apiClient: serviceProvider.apiClient)
	}()

	lazy var getNfts: GetNftsUseCase = {
		.init(apiClient: serviceProvider.apiClient)
	}()

	lazy var getAuthor: GetAuthorUseCase = {
		.init(apiClient: serviceProvider.apiClient)
	}()

	lazy var getLikes: GetLikesUseCase = {
		.init(apiClient: serviceProvider.apiClient)
	}()

	lazy var putLikes: PutLikesUseCase = {
		.init(apiClient: serviceProvider.apiClient)
	}()

	lazy var getOrder: GetOrderUseCase = {
		.init(apiClient: serviceProvider.apiClient)
	}()

	lazy var putOrder: PutOrderUseCase = {
		.init(apiClient: serviceProvider.apiClient)
	}()
}
