import Foundation

protocol ErrorModuleFactory {
	func makeErrorAlertVC(
		message: String,
		completion: (() -> Void)?
	) -> Presentable
}

protocol CommonModuleFactory: ErrorModuleFactory {
	func makeWebViewController(
		url: URL,
		completion: @escaping (() -> Void)
	) -> Presentable
	func makeSortAlertVC<T: CustomStringConvertible>(
		sortCases: [T],
		completion: @escaping (T) -> Void
	) -> Presentable
}

protocol StartModuleFactory: ErrorModuleFactory {
	func makeSplashViewController(viewModel: SplashViewModel) -> Presentable
}

protocol OnboardingModuleFactory {
	func makeOnboardingViewController(
		viewModel: OnboardingViewModel,
		pagesData: [OnboardingPageData],
		onShowPage: ((Int) -> Void)?
	) -> Presentable
}

protocol AuthModuleFactory {
	func makeAuthViewController(viewModel: AuthViewModel) -> Presentable
}

protocol ProfileModuleFactory: CommonModuleFactory {
	func makeProfileViewController(viewModel: ProfileViewModel) -> Presentable
	func makeEditProfileViewController(viewModel: ProfileViewModel) -> Presentable
	func makeMyNftsViewController(viewModel: MyNftsViewModel) -> Presentable
	func makeFavoritesViewController(viewModel: FavoritesViewModel) -> Presentable
}

protocol CatalogModuleFactory: CommonModuleFactory {
	func makeCatalogViewController(viewModel: CatalogViewModel) -> Presentable
	func makeCollectionViewController(viewModel: CollectionViewModel) -> Presentable
}

protocol ShoppingCartModuleFactory {
	func makeShoppinCartViewController(viewModel: ShoppingCartViewModel) -> Presentable
}

protocol StatisticsModuleFactory {
	func makeStatisticsViewController(viewModel: StatisticsViewModel) -> Presentable
}
