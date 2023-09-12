protocol CatalogFlowDIContainer {
	func makeCatalogViewModel() -> CatalogViewModel
	func makeCollectionViewModel(collection: Collection) -> CollectionViewModel
}

final class CatalogFlowDIContainerImp: CatalogFlowDIContainer {
	struct Dependencies {
		let getSetSortOption: SortCollectionsOption
		let getNfts: GetNftsProfileUseCase
		let putLike: PutLikeByIDUseCase
		let putNftToOrder: PutNftToOrderByIDUseCase

		let collectionsRepository: CollectionsRepository
		let authorsRepository: AuthorsRepository
		let likesIDsRepository: NftsIDsRepository
		let orderIDsRepository: NftsIDsRepository
	}

	private let dependencies: Dependencies

	init(dependencies: Dependencies) {
		self.dependencies = dependencies
	}

	func makeCatalogViewModel() -> CatalogViewModel {
		let dep = DefaultCatalogViewModel.Dependencies(
			getSetSortOption: dependencies.getSetSortOption,
			collectionsRepository: dependencies.collectionsRepository
		)

		return DefaultCatalogViewModel(dep: dep)
	}

	func makeCollectionViewModel(collection: Collection) -> CollectionViewModel {
		let dep = DefaultCollectionViewModel.Dependencies(
			collection: collection,
			getNfts: dependencies.getNfts,
			putLike: dependencies.putLike,
			putNftToOrder: dependencies.putNftToOrder,

			collectionsRepository: dependencies.collectionsRepository,
			authorsRepository: dependencies.authorsRepository,
			likesIDsRepository: dependencies.likesIDsRepository,
			orderIDsRepository: dependencies.orderIDsRepository
		)

		return DefaultCollectionViewModel(dep: dep)
	}
}
