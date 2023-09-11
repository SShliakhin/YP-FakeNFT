protocol ProfileFlowDIContainer {
	func makeProfileViewModel() -> ProfileViewModel
	func makeMyNftsViewModel() -> MyNftsViewModel
	func makeFavoritesViewModel() -> FavoritesViewModel
	func makeSearchNftsViewModel() -> MyNftsViewModel
}

final class ProfileFlowDIContainerImp: ProfileFlowDIContainer {
	struct Dependencies {
		let getProfile: GetProfileUseCase
		let putProfile: PutProfileUseCase
		let getMyNfts: GetNftsProfileUseCase
		let getSetSortOption: SortMyNtfsOption
		let getAuthors: GetAuthorsUseCase
		let putLike: PutLikeByIDUseCase
		let profileRepository: ProfileRepository
		let likesIDsRepository: NftsIDsRepository
		let myNftsIDsRepository: NftsIDsRepository
		let searchNftsByName: SearchNftsByNameUseCase
	}

	private let dependencies: Dependencies

	init(dependencies: Dependencies) {
		self.dependencies = dependencies
	}

	func makeProfileViewModel() -> ProfileViewModel {
		let dep = DefaultProfileViewModel.Dependencies(
			getProfile: dependencies.getProfile,
			putProfile: dependencies.putProfile,
			profileRepository: dependencies.profileRepository,
			likesIDRepository: dependencies.likesIDsRepository,
			myNftsIDsRepository: dependencies.myNftsIDsRepository
		)

		return DefaultProfileViewModel(dep: dep)
	}

	func makeMyNftsViewModel() -> MyNftsViewModel {
		let dep = DefaultMyNftsViewModel.Dependencies(
			getMyNfts: dependencies.getMyNfts,
			getSetSortOption: dependencies.getSetSortOption,
			putLike: dependencies.putLike,
			getAuthors: dependencies.getAuthors,
			likesIDsRepository: dependencies.likesIDsRepository,
			myNftsIDsRepository: dependencies.myNftsIDsRepository
		)

		return DefaultMyNftsViewModel(dep: dep)
	}

	func makeFavoritesViewModel() -> FavoritesViewModel {
		let dep = DefaultFavoritesViewModel.Dependencies(
			getNfts: dependencies.getMyNfts,
			putLike: dependencies.putLike,
			likesIDsRepository: dependencies.likesIDsRepository
		)

		return DefaultFavoritesViewModel(dep: dep)
	}

	func makeSearchNftsViewModel() -> MyNftsViewModel {
		let dep = SearchNftsViewModel.Dependencies(
			searchNftsByName: dependencies.searchNftsByName,
			getSetSortOption: dependencies.getSetSortOption,
			putLike: dependencies.putLike,
			getAuthors: dependencies.getAuthors,
			likesIDsRepository: dependencies.likesIDsRepository
		)

		return SearchNftsViewModel(dep: dep)
	}
}
