import UIKit

struct ProfileFlow: IFlow {
	let profileModuleFactory: ProfileModuleFactory
	let profileDIContainer: ProfileFlowDIContainer

	func start() -> UIViewController {
		showProfile()
	}

	func showProfile() -> UIViewController {
		let viewModel = profileDIContainer.makeProfileViewModel()
		let view = profileModuleFactory.makeProfileViewController(viewModel: viewModel)
		// swiftlint:disable:next closure_body_length
		viewModel.didSendEventClosure = { [weak view, weak viewModel] event in
			switch event {

			case .showErrorAlert(let message, let withRetry):
				let alert = makeErrorAlert(message: message, withRetry: withRetry) {
					viewModel?.didUserDo(request: .retryAction)
				}
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
		let viewModel = profileDIContainer.makeMyNftsViewModel()
		let view = profileModuleFactory.makeMyNftsViewController(viewModel: viewModel)
		viewModel.didSendEventClosure = { [weak view, weak viewModel] event in
			switch event {

			case .showErrorAlert(let message, let withRetry):
				let alert = makeErrorAlert(message: message, withRetry: withRetry) {
					viewModel?.didUserDo(request: .retryAction)
				}
				view?.present(alert, animated: true)

			case .showSortAlert:
				let alert = profileModuleFactory.makeSortAlertVC(
					sortCases: [.price, .rating, .name]
				) {
					viewModel?.didUserDo(request: .selectSortBy($0))
				}
				view?.present(alert, animated: true)

			case .close:
				view?.navigationController?.popViewController(animated: true)
			}
		}

		return view
	}

	func makeFavoritesVC() -> UIViewController {
		let viewModel = profileDIContainer.makeFavoritesViewModel()
		let view = profileModuleFactory.makeFavoritesViewController(viewModel: viewModel)
		viewModel.didSendEventClosure = { [weak view, weak viewModel] event in
			switch event {

			case .showErrorAlert(let message, withRetry: let withRetry):
				let alert = makeErrorAlert(message: message, withRetry: withRetry) {
					viewModel?.didUserDo(request: .retryAction)
				}
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

	func makeErrorAlert(message: String, withRetry: Bool, completion: (() -> Void)?) -> UIViewController {
		profileModuleFactory.makeErrorAlertVC(
			message: message,
			completion: withRetry ? completion : nil
		)
	}
}
