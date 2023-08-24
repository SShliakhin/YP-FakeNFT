import UIKit

struct ProfileFlow: IFlow {
	func start() -> UIViewController {
		showProfile()
	}

	func showProfile() -> UIViewController {
		let dep = DefaultProfileViewModel.Dependencies(
			getProfile: ProfileUseCaseProvider.instance.getProfile,
			putProfile: ProfileUseCaseProvider.instance.putProfile
		)
		let viewModel: ProfileViewModel = DefaultProfileViewModel(dep: dep)
		let view = ProfileViewController(viewModel: viewModel)
		// swiftlint:disable:next closure_body_length
		viewModel.didSendEventClosure = { [weak view, weak viewModel] event in
			switch event {

			case .showErrorAlert(let message, let withRetry):
				let alert = makeErrorAlertVC(
					message: message,
					completion: withRetry
					? { viewModel?.didUserDo(request: .retryAction) }
					: nil
				)
				view?.present(alert, animated: true)

			case .selectEditProfile:
				guard let viewModel = viewModel else { return }
				let editProfileView = EditProfileViewController(viewModel: viewModel)
				view?.present(editProfileView, animated: true)

			case .selectMyNfts(let profile):
				let myNftsVC = makeMyNftsVC(profile: profile)
				view?.show(myNftsVC, sender: view)

			case .selectFavorites(let profile):
				let favoritesVC = makeFavoritesVC(profile: profile)
				view?.show(favoritesVC, sender: view)

			case .selectAbout(let url):
				if let url = url {
					let webViewVC = makeWebViewVC(url: url)
					view?.show(webViewVC, sender: view)
				} else {
					let alert = makeErrorAlertVC(message: Theme.Profile.incorrectURL)
					view?.present(alert, animated: true)
				}

			case .close:
				view?.presentedViewController?.dismiss(animated: true)
			}
		}

		return view
	}

	func makeEditProfileVC(profileVM: ProfileViewModel) -> UIViewController {
		let view = EditProfileViewController(viewModel: profileVM)

		return view
	}

	func makeMyNftsVC(profile: Profile) -> UIViewController {
		let dep = DefaultMyNftsViewModel.Dependencies(
			profile: profile,
			getMyNfts: ProfileUseCaseProvider.instance.getNfts,
			getSetSortOption: ProfileUseCaseProvider.instance.getSetSortMyNtfsOption,
			putLikes: ProfileUseCaseProvider.instance.putLikes,
			getAuthors: ProfileUseCaseProvider.instance.getAuthors
		)
		let viewModel = DefaultMyNftsViewModel(dep: dep)
		let view = MyNftsViewController(viewModel: viewModel)
		viewModel.didSendEventClosure = { [weak view, weak viewModel] event in
			switch event {

			case .showErrorAlert(let message, let withRetry):
				let alert = makeErrorAlertVC(
					message: message,
					completion: withRetry
					? { viewModel?.didUserDo(request: .retryAction) }
					: nil
				)
				view?.present(alert, animated: true)

			case .showSortAlert:
				let alert = makeSortAlertVC(
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

	func makeFavoritesVC(profile: Profile) -> UIViewController {
		let dep = DefaultFavoritesViewModel.Dependencies(
			profile: profile,
			getMyNfts: ProfileUseCaseProvider.instance.getNfts,
			putLikes: ProfileUseCaseProvider.instance.putLikes
		)
		let viewModel = DefaultFavoritesViewModel(dep: dep)
		let view = FavoritesViewController(viewModel: viewModel)
		viewModel.didSendEventClosure = { [weak view, weak viewModel] event in
			switch event {

			case .showErrorAlert(let message, withRetry: let withRetry):
				let alert = makeErrorAlertVC(
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
		let view = WebViewController(viewModel: viewModel)
		viewModel.didSendEventClosure = { [weak view] event in
			switch event {
			case .close:
				view?.navigationController?.popViewController(animated: true)
			}
		}

		return view
	}

	func makeSortAlertVC(
		sortCases: [SortMyNftsBy],
		completion: @escaping (SortMyNftsBy) -> Void
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
}
