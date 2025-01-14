import UIKit

final class ModuleFactoryImp: ErrorModuleFactory,
	CommonModuleFactory,
	StartModuleFactory,
	OnboardingModuleFactory,
	AuthModuleFactory,
	ProfileModuleFactory,
	CatalogModuleFactory,
	ShoppingCartModuleFactory,
	StatisticsModuleFactory {

	// MARK: - CommonModuleFactory
	func makeWebViewController(url: URL, completion: @escaping (() -> Void)) -> Presentable {
		let dep = DefaultWebViewModel.Dependencies(url: url)
		let viewModel = DefaultWebViewModel(dep: dep)
		viewModel.didSendEventClosure = { event in
			switch event {
			case .close:
				completion()
			}
		}

		return WebViewController(viewModel: viewModel)
	}
	func makeErrorAlertVC(
		message: String,
		completion: (() -> Void)? = nil
	) -> Presentable {
		let alert = UIAlertController(
			title: L10n.AlertTitles.errorTitle,
			message: message,
			preferredStyle: .alert
		)
		if let completion = completion {
			alert.addAction(
				UIAlertAction(title: L10n.ActionsNames.retry, style: .default) { _ in
					completion()
				}
			)
		} else {
			alert.addAction(
				UIAlertAction(title: L10n.ActionsNames.okey, style: .default)
			)
		}

		return alert
	}
	func makeSortAlertVC<T: CustomStringConvertible>(
		sortCases: [T],
		completion: @escaping (T) -> Void
	) -> Presentable {
		let alert = UIAlertController(
			title: L10n.AlertTitles.sortTitle,
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
			UIAlertAction(title: L10n.ActionsNames.close, style: .cancel)
		)

		return alert
	}

	// MARK: - StartModuleFactory
	func makeSplashViewController(viewModel: SplashViewModel) -> Presentable {
		SplashViewController(viewModel: viewModel)
	}

	// MARK: - OnboardingModuleFactory
	func makeOnboardingViewController(
		viewModel: OnboardingViewModel,
		pagesData: [OnboardingPageData],
		onShowPage: ((Int) -> Void)?
	) -> Presentable {
		OnboardingViewController(
			viewModel: viewModel,
			pageViewController: makePageViewController(
				pagesData: pagesData,
				onShowPage: onShowPage
			)
		)
	}

	private func makePageViewController(
		pagesData: [OnboardingPageData],
		onShowPage: ((Int) -> Void)?
	) -> PageViewController {
		var pages: [UIViewController] = []
		for page in pagesData {
			pages.append(OnboardingPageViewController(page: page))
		}

		return PageViewControllerImp(pages: pages, onShowPage: onShowPage)
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
		let module = EditProfileViewController(viewModel: viewModel)
		module.modalTransitionStyle = .flipHorizontal
		return module
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
