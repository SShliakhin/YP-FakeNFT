protocol CatalogFlowDIContainer {
	func makeCatalogViewModel() -> CatalogViewModel
	func makeCollectionViewModel(collection: Collection) -> CollectionViewModel
}

final class CatalogFlowDIContainerImp: CatalogFlowDIContainer {
	struct Dependencies {
		let getCollections: GetCollectionsUseCase
		let getSetSortOption: SortCollectionsOption
		let getAuthor: GetAuthorsUseCase
		let getNfts: GetNftsProfileUseCase
		let putLike: PutLikeByIDUseCase
		let getOrder: GetOrderUseCase
		let putOrder: PutOrderUseCase
		let likesIDsRepository: NftsIDsRepository
	}

	private let dependencies: Dependencies

	init(dependencies: Dependencies) {
		self.dependencies = dependencies
	}

	func makeCatalogViewModel() -> CatalogViewModel {
		let dep = DefaultCatalogViewModel.Dependencies(
			getCollections: dependencies.getCollections,
			getSetSortOption: dependencies.getSetSortOption
		)

		return DefaultCatalogViewModel(dep: dep)
	}

	func makeCollectionViewModel(collection: Collection) -> CollectionViewModel {
		let dep = DefaultCollectionViewModel.Dependencies(
			collection: collection,
			getAuthor: dependencies.getAuthor,
			getNfts: dependencies.getNfts,
			putLike: dependencies.putLike,
			getOrder: dependencies.getOrder,
			putOrder: dependencies.putOrder,
			likesIDsRepository: dependencies.likesIDsRepository
		)

		return DefaultCollectionViewModel(dep: dep)
	}
}
