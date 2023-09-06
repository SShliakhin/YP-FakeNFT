import Foundation

protocol CommonModuleFactory {
	func makeSplashViewController() -> Presentable
	func makeWebViewController(url: URL, completion: @escaping (() -> Void)) -> Presentable
	func makeErrorAlertVC(message: String, completion: (() -> Void)?) -> Presentable
	func makeSortAlertVC<T: CustomStringConvertible>(sortCases: [T], completion: @escaping (T) -> Void) -> Presentable
}

protocol OnboardingModuleFactory {
	func makeOnboardingViewController(viewModel: OnboardingViewModel) -> Presentable
}

protocol AuthModuleFactory {
	func makeAuthViewController(viewModel: AuthViewModel) -> Presentable
}

protocol ProfileModuleFactory {
	func makeProfileViewController(viewModel: ProfileViewModel) -> Presentable
	func makeEditProfileViewController(viewModel: ProfileViewModel) -> Presentable
	func makeMyNftsViewController(viewModel: MyNftsViewModel) -> Presentable
	func makeFavoritesViewController(viewModel: FavoritesViewModel) -> Presentable

	func makeWebViewController(url: URL, completion: @escaping (() -> Void)) -> Presentable
	func makeErrorAlertVC(message: String, completion: (() -> Void)?) -> Presentable
	func makeSortAlertVC<T: CustomStringConvertible>(sortCases: [T], completion: @escaping (T) -> Void) -> Presentable
}

protocol CatalogModuleFactory {
	func makeCatalogViewController(viewModel: CatalogViewModel) -> Presentable
	func makeCollectionViewController(viewModel: CollectionViewModel) -> Presentable

	func makeWebViewController(url: URL, completion: @escaping (() -> Void)) -> Presentable
	func makeErrorAlertVC(message: String, completion: (() -> Void)?) -> Presentable
	func makeSortAlertVC<T: CustomStringConvertible>(sortCases: [T], completion: @escaping (T) -> Void) -> Presentable
}

protocol ShoppingCartModuleFactory {
	func makeShoppinCartViewController(viewModel: ShoppingCartViewModel) -> Presentable
}

protocol StatisticsModuleFactory {
	func makeStatisticsViewController(viewModel: StatisticsViewModel) -> Presentable
}
