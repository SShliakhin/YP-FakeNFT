import UIKit // потом убрать

final class ModuleFactoryImp: CommonModuleFactory,
	OnboardingModuleFactory,
	AuthModuleFactory,
	ProfileModuleFactory,
	CatalogModuleFactory,
	ShoppingCartModuleFactory,
	StatisticsModuleFactory {

	// MARK: - CommonModuleFactory

	func makeMainTabBarController() -> UIViewController {
		MainTabBarController()
	}
	func makeSplashViewController() -> UIViewController {
		SplashViewController()
	}
	func makeWebViewController(viewModel: WebViewModel) -> UIViewController {
		WebViewController(viewModel: viewModel)
	}
	func makeErrorAlertVC(
		message: String,
		completion: (() -> Void)? = nil
	) -> UIViewController {
		let alert = UIAlertController(
			title: Theme.AlertTitles.errorTitle,
			message: message,
			preferredStyle: .alert
		)
		if let completion = completion {
			alert.addAction(
				UIAlertAction(title: Theme.ActionsNames.retry, style: .default) { _ in
					completion()
				}
			)
		} else {
			alert.addAction(
				UIAlertAction(title: Theme.ActionsNames.okey, style: .default)
			)
		}

		return alert
	}
	func makeSortAlertVC<T: CustomStringConvertible>(
		sortCases: [T],
		completion: @escaping (T) -> Void
	) -> UIViewController {
		let alert = UIAlertController(
			title: Theme.AlertTitles.sortTitle,
			message: nil,
			preferredStyle: .actionSheet
		)
		sortCases.forEach { sortCase in
			alert.addAction(
				UIAlertAction(title: sortCase.description, style: .default) { _ in
					completion(sortCase)
				}
			)
		}
		alert.addAction(
			UIAlertAction(title: Theme.ActionsNames.close, style: .cancel)
		)

		return alert
	}

	// MARK: - OnboardingModuleFactory
	func makeOnboardingViewController() -> UIViewController {
		SplashViewController()
	}

	// MARK: - AuthModuleFactory
	func makeAuthViewController() -> UIViewController {
		SplashViewController()
	}

	// MARK: - ProfileModuleFactory
	func makeProfileViewController(viewModel: ProfileViewModel) -> UIViewController {
		ProfileViewController(viewModel: viewModel)
	}
	func makeEditProfileViewController(viewModel: ProfileViewModel) -> UIViewController {
		EditProfileViewController(viewModel: viewModel)
	}
	func makeMyNftsViewController(viewModel: MyNftsViewModel) -> UIViewController {
		MyNftsViewController(viewModel: viewModel)
	}
	func makeFavoritesViewController(viewModel: FavoritesViewModel) -> UIViewController {
		FavoritesViewController(viewModel: viewModel)
	}

	// MARK: - CatalogModuleFactory
	func makeCatalogViewController(viewModel: CatalogViewModel) -> UIViewController {
		CatalogViewController(viewModel: viewModel)
	}
	func makeCollectionViewController(viewModel: CollectionViewModel) -> UIViewController {
		CollectionViewController(viewModel: viewModel)
	}

	// MARK: - ShoppingCartModuleFactory
	// MARK: - StatisticsModuleFactory
}
