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
		let putLikes: PutLikesProfileUseCase
		let getAuthors: GetAuthorsUseCase
		let profileRepository: ProfileRepository
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
			profileRepository: dependencies.profileRepository
		)

		return DefaultProfileViewModel(dep: dep)
	}

	func makeMyNftsViewModel() -> MyNftsViewModel {
		let dep = DefaultMyNftsViewModel.Dependencies(
			getMyNfts: dependencies.getMyNfts,
			getSetSortOption: dependencies.getSetSortOption,
			putLikes: dependencies.putLikes,
			getAuthors: dependencies.getAuthors,
			profileRepository: dependencies.profileRepository
		)

		return DefaultMyNftsViewModel(dep: dep)
	}

	func makeFavoritesViewModel() -> FavoritesViewModel {
		let dep = DefaultFavoritesViewModel.Dependencies(
			getNfts: dependencies.getMyNfts,
			putLikes: dependencies.putLikes,
			profileRepository: dependencies.profileRepository
		)

		return DefaultFavoritesViewModel(dep: dep)
	}

	func makeSearchNftsViewModel() -> MyNftsViewModel {
		let dep = SearchNftsViewModel.Dependencies(
			searchNftsByName: dependencies.searchNftsByName,
			getSetSortOption: dependencies.getSetSortOption,
			putLikes: dependencies.putLikes,
			getAuthors: dependencies.getAuthors,
			profileRepository: dependencies.profileRepository
		)

		return SearchNftsViewModel(dep: dep)
	}
}
