import Foundation

final class ProfileCoordinator: BaseCoordinator {
	private let container: ProfileFlowDIContainer
	private let factory: ProfileModuleFactory
	private let router: Router

	init(router: Router, factory: ProfileModuleFactory, container: ProfileFlowDIContainer) {
		self.router = router
		self.factory = factory
		self.container = container
	}

	override func start() {
		showProfileModule()
	}

	deinit {
		print("ProfileCoordinator deinit")
	}
}

// MARK: - show Modules
private extension ProfileCoordinator {
	func showProfileModule() {
		let viewModel = container.makeProfileViewModel()
		let module = factory.makeProfileViewController(viewModel: viewModel)

		viewModel.didSendEventClosure = { [weak self, weak viewModel] event in
			switch event {

			case .showErrorAlert(let message, let withRetry):
				self?.presentErrorAlert(message: message, withRetry: withRetry) {
					viewModel?.didUserDo(request: .retryAction)
				}

			case .selectEditProfile:
				guard let viewModel = viewModel else { return }
				self?.presentEditProfileModule(viewModel: viewModel)

			case .selectMyNfts:
				self?.pushMyNftsVC()

			case .selectFavorites:
				self?.pushFavoritesVC()

			case .selectAbout(let url):
				if let url = url {
					self?.pushWebViewVC(url: url)
				} else {
					self?.presentErrorAlert(message: L10n.Profile.incorrectURL)
				}

			case .close:
				self?.router.dismissModule()
			}
		}

		router.setRootModule(module)
	}

	func presentEditProfileModule(viewModel: ProfileViewModel) {
		let module = factory.makeEditProfileViewController(viewModel: viewModel)
		router.present(module)
	}

	func pushMyNftsVC() {
		let viewModel = container.makeMyNftsViewModel()
		let module = factory.makeMyNftsViewController(viewModel: viewModel)

		viewModel.didSendEventClosure = { [weak self, weak viewModel] event in
			switch event {

			case .showErrorAlert(let message, let withRetry):
				self?.presentErrorAlert(message: message, withRetry: withRetry) {
					viewModel?.didUserDo(request: .retryAction)
				}

			case .showSortAlert:
				let alert = self?.factory
					.makeSortAlertVC(sortCases: [.price, .rating, .name]) {
						viewModel?.didUserDo(request: .selectSortBy($0))
					}
				self?.router.present(alert)

			case .close:
				self?.router.popModule()
			}
		}

		router.push(module)
	}

	func pushFavoritesVC() {
		let viewModel = container.makeFavoritesViewModel()
		let module = factory.makeFavoritesViewController(viewModel: viewModel)
		viewModel.didSendEventClosure = { [weak self, weak viewModel] event in
			switch event {

			case .showErrorAlert(let message, withRetry: let withRetry):
				self?.presentErrorAlert(message: message, withRetry: withRetry) {
					viewModel?.didUserDo(request: .retryAction)
				}

			case .close:
				self?.router.popModule()
			}
		}

		router.push(module)
	}

	func presentErrorAlert(
		message: String,
		withRetry: Bool = false,
		completion: (() -> Void)? = nil
	) {
		let module = factory.makeErrorAlertVC(
			message: message,
			completion: withRetry ? completion : nil
		)
		router.present(module)
	}

	func pushWebViewVC(url: URL) {
		let module = factory
			.makeWebViewController(url: url) { [weak self] in
				self?.router.popModule()
			}
		router.push(module)
	}
}
