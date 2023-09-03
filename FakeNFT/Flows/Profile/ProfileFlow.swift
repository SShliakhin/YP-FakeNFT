import UIKit

struct ProfileFlow: IFlow {
	private let profileModuleFactory: ProfileModuleFactory = ModuleFactoryImp()

	func start() -> UIViewController {
		showProfile()
	}

	func showProfile() -> UIViewController {
		let dep = DefaultProfileViewModel.Dependencies(
			getProfile: UseCaseProvider.instance.getProfile,
			putProfile: UseCaseProvider.instance.putProfile,
			profileRepository: UseCaseProvider.instance.profileRepository
		)
		let viewModel: ProfileViewModel = DefaultProfileViewModel(dep: dep)
		let view = profileModuleFactory.makeProfileViewController(viewModel: viewModel)
		// swiftlint:disable:next closure_body_length
		viewModel.didSendEventClosure = { [weak view, weak viewModel] event in
			switch event {

			case .showErrorAlert(let message, let withRetry):
				let alert = profileModuleFactory.makeErrorAlertVC(
					message: message,
					completion: withRetry
					? { viewModel?.didUserDo(request: .retryAction) }
					: nil
				)
				view?.present(alert, animated: true)

			case .selectEditProfile:
				guard let viewModel = viewModel else { return }
				let editProfileView = profileModuleFactory.makeEditProfileViewController(viewModel: viewModel)
				view?.present(editProfileView, animated: true)

			case .selectMyNfts:
				let myNftsVC = makeMyNftsVC()
				view?.show(myNftsVC, sender: view)

			case .selectFavorites:
				let favoritesVC = makeFavoritesVC()
				view?.show(favoritesVC, sender: view)

			case .selectAbout(let url):
				if let url = url {
					let webViewVC = makeWebViewVC(url: url)
					view?.show(webViewVC, sender: view)
				} else {
					let alert = profileModuleFactory.makeErrorAlertVC(
						message: Theme.Profile.incorrectURL,
						completion: nil
					)
					view?.present(alert, animated: true)
				}

			case .close:
				view?.presentedViewController?.dismiss(animated: true)
			}
		}

		return view
	}

	func makeMyNftsVC() -> UIViewController {
		let dep = DefaultMyNftsViewModel.Dependencies(
			getMyNfts: UseCaseProvider.instance.getNfts,
			getSetSortOption: UseCaseProvider.instance.getSetSortMyNtfsOption,
			putLikes: UseCaseProvider.instance.putLikes,
			getAuthors: UseCaseProvider.instance.getAuthors,
			profileRepository: UseCaseProvider.instance.profileRepository
		)
		let viewModel = DefaultMyNftsViewModel(dep: dep)
		let view = profileModuleFactory.makeMyNftsViewController(viewModel: viewModel)
		viewModel.didSendEventClosure = { [weak view, weak viewModel] event in
			switch event {

			case .showErrorAlert(let message, let withRetry):
				let alert = profileModuleFactory.makeErrorAlertVC(
					message: message,
					completion: withRetry
					? { viewModel?.didUserDo(request: .retryAction) }
					: nil
				)
				view?.present(alert, animated: true)

			case .showSortAlert:
				let alert = profileModuleFactory.makeSortAlertVC(
					sortCases: [.price, .rating, .name],
					completion: { viewModel?.didUserDo(request: .selectSortBy($0)) }
				)
				view?.present(alert, animated: true)

			case .close:
				view?.navigationController?.popViewController(animated: true)
			}
		}

		return view
	}

	func makeFavoritesVC() -> UIViewController {
		let dep = DefaultFavoritesViewModel.Dependencies(
			getNfts: UseCaseProvider.instance.getNfts,
			putLikes: UseCaseProvider.instance.putLikes,
			profileRepository: UseCaseProvider.instance.profileRepository
		)
		let viewModel = DefaultFavoritesViewModel(dep: dep)
		let view = profileModuleFactory.makeFavoritesViewController(viewModel: viewModel)
		viewModel.didSendEventClosure = { [weak view, weak viewModel] event in
			switch event {

			case .showErrorAlert(let message, withRetry: let withRetry):
				let alert = profileModuleFactory.makeErrorAlertVC(
					message: message,
					completion: withRetry
					? { viewModel?.didUserDo(request: .retryAction) }
					: nil
				)
				view?.present(alert, animated: true)

			case .close:
				view?.navigationController?.popViewController(animated: true)
			}
		}

		return view
	}

	func makeWebViewVC(url: URL) -> UIViewController {
		let dep = DefaultWebViewModel.Dependencies(url: url)
		let viewModel = DefaultWebViewModel(dep: dep)
		let view = profileModuleFactory.makeWebViewController(viewModel: viewModel)
		viewModel.didSendEventClosure = { [weak view] event in
			switch event {
			case .close:
				view?.navigationController?.popViewController(animated: true)
			}
		}

		return view
	}
}
