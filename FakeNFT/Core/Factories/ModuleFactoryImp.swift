import UIKit // потом убрать

final class ModuleFactoryImp: CommonModuleFactory,
	OnboardingModuleFactory,
	AuthModuleFactory,
	ProfileModuleFactory,
	CatalogModuleFactory,
	ShoppingCartModuleFactory,
	StatisticsModuleFactory {

	// MARK: - CommonModuleFactory
	func makeSplashViewController() -> Presentable {
		SplashViewController()
	}
	func makeWebViewController(viewModel: WebViewModel) -> Presentable {
		WebViewController(viewModel: viewModel)
	}
	func makeErrorAlertVC(
		message: String,
		completion: (() -> Void)? = nil
	) -> Presentable {
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
	) -> Presentable {
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
	func makeOnboardingViewController(viewModel: OnboardingViewModel) -> Presentable {
		OnboardingViewController(viewModel: viewModel)
	}

	// MARK: - AuthModuleFactory
	func makeAuthViewController(viewModel: AuthViewModel) -> Presentable {
		AuthViewController(viewModel: viewModel)
	}

	// MARK: - ProfileModuleFactory
	func makeProfileViewController(viewModel: ProfileViewModel) -> Presentable {
		ProfileViewController(viewModel: viewModel)
	}
	func makeEditProfileViewController(viewModel: ProfileViewModel) -> Presentable {
		EditProfileViewController(viewModel: viewModel)
	}
	func makeMyNftsViewController(viewModel: MyNftsViewModel) -> Presentable {
		MyNftsViewController(viewModel: viewModel)
	}
	func makeFavoritesViewController(viewModel: FavoritesViewModel) -> Presentable {
		FavoritesViewController(viewModel: viewModel)
	}

	// MARK: - CatalogModuleFactory
	func makeCatalogViewController(viewModel: CatalogViewModel) -> Presentable {
		CatalogViewController(viewModel: viewModel)
	}
	func makeCollectionViewController(viewModel: CollectionViewModel) -> Presentable {
		CollectionViewController(viewModel: viewModel)
	}

	// MARK: - ShoppingCartModuleFactory
	func makeShoppinCartViewController(viewModel: ShoppingCartViewModel) -> Presentable {
		ShoppingCartViewController()
	}

	// MARK: - StatisticsModuleFactory
	func makeStatisticsViewController(viewModel: StatisticsViewModel) -> Presentable {
		StatisticsViewController()
	}
}
