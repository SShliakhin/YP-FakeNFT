import Foundation

final class AppDIContainer {
	private let session = URLSession(configuration: .default)

	// MARK: - Network
	lazy var apiClient: APIClient = {
		APIClient(session: session)
	}()

	// MARK: - Repository
	lazy var profileRepository: ProfileRepository = {
		ProfileRepositoryImp()
	}()

	// MARK: - UseCases
	lazy var useCases: UseCaseProvider = {
		let dep = UseCaseProvider.Dependencies(
			apiClient: apiClient,
			profileRepository: profileRepository
		)
		return UseCaseProvider(dependencies: dep)
	}()

	// MARK: - DIContainers of flows
	func makeOnboardingFlowDIContainer() -> OnboardingFlowDIContainer {
		OnboardingFlowDIContainer()
	}

	func makeAuthFlowDIContainer() -> AuthFlowDIContainer {
		AuthFlowDIContainer()
	}

	func makeMainFlowDIContainer() -> MainFlowDIContainer {
		MainFlowDIContainer()
	}

	func makeProfileFlowDIContainer() -> ProfileFlowDIContainer {
		let dep = ProfileFlowDIContainerImp.Dependencies(
			getProfile: useCases.getProfile,
			putProfile: useCases.putProfile,
			getMyNfts: useCases.getNfts,
			getSetSortOption: useCases.getSetSortMyNtfsOption,
			putLikes: useCases.putLikes,
			getAuthors: useCases.getAuthors,
			profileRepository: profileRepository
		)
		return ProfileFlowDIContainerImp(dependencies: dep)
	}

	func makeCatalogFlowDIContainer() -> CatalogFlowDIContainer {
		let dep = CatalogFlowDIContainerImp.Dependencies(
			getCollections: useCases.getCollections,
			getSetSortOption: useCases.getSetSortCollectionsOption,
			getAuthor: useCases.getAuthors,
			getNfts: useCases.getNfts,
			getLikes: useCases.getLikes,
			putLikes: useCases.putLikes,
			getOrder: useCases.getOrder,
			putOrder: useCases.putOrder
		)
		return CatalogFlowDIContainerImp(dependencies: dep)
	}
}

final class OnboardingFlowDIContainer {}

final class AuthFlowDIContainer {}

final class MainFlowDIContainer {}
