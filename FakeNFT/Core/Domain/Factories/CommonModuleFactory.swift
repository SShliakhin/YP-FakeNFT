import UIKit // потом убрать

protocol CommonModuleFactory {
	func makeMainTabBarController() -> UIViewController
	func makeSplashViewController() -> UIViewController
	func makeWebViewController(viewModel: WebViewModel) -> UIViewController
	func makeErrorAlertVC(message: String, completion: (() -> Void)?) -> UIViewController
	func makeSortAlertVC<T: CustomStringConvertible>(sortCases: [T], completion: @escaping (T) -> Void) -> UIViewController
}

protocol OnboardingModuleFactory {
	func makeOnboardingViewController() -> UIViewController
}

protocol AuthModuleFactory {
	func makeAuthViewController() -> UIViewController
}

protocol ProfileModuleFactory {
	func makeProfileViewController(viewModel: ProfileViewModel) -> UIViewController
	func makeEditProfileViewController(viewModel: ProfileViewModel) -> UIViewController
	func makeMyNftsViewController(viewModel: MyNftsViewModel) -> UIViewController
	func makeFavoritesViewController(viewModel: FavoritesViewModel) -> UIViewController

	func makeWebViewController(viewModel: WebViewModel) -> UIViewController
	func makeErrorAlertVC(message: String, completion: (() -> Void)?) -> UIViewController
	func makeSortAlertVC<T: CustomStringConvertible>(sortCases: [T], completion: @escaping (T) -> Void) -> UIViewController
}

protocol CatalogModuleFactory {
	func makeCatalogViewController(viewModel: CatalogViewModel) -> UIViewController
	func makeCollectionViewController(viewModel: CollectionViewModel) -> UIViewController

	func makeWebViewController(viewModel: WebViewModel) -> UIViewController
	func makeErrorAlertVC(message: String, completion: (() -> Void)?) -> UIViewController
	func makeSortAlertVC<T: CustomStringConvertible>(sortCases: [T], completion: @escaping (T) -> Void) -> UIViewController
}

protocol ShoppingCartModuleFactory {}

protocol StatisticsModuleFactory {}
