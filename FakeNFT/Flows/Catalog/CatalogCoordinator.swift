import Foundation

final class CatalogCoordinator: BaseCoordinator {
	private let container: CatalogFlowDIContainer
	private let factory: CatalogModuleFactory
	private let router: Router

	init(router: Router, factory: CatalogModuleFactory, container: CatalogFlowDIContainer) {
		self.router = router
		self.factory = factory
		self.container = container
	}

	override func start() {
		showCatalog()
	}

	deinit {
		print("CatalogCoordinator deinit")
	}
}

// MARK: - show Modules
private extension CatalogCoordinator {
	func showCatalog() {
		let viewModel = container.makeCatalogViewModel()
		let module = factory.makeCatalogViewController(viewModel: viewModel)

		viewModel.didSendEventClosure = { [weak self, weak viewModel] event in
			switch event {

			case .showErrorAlert(let message):
				self?.presentErrorAlert(message: message, withRetry: true) {
					viewModel?.didUserDo(request: .retryAction)
				}

			case .showSortAlert:
				let alert = self?.factory
					.makeSortAlertVC(sortCases: [.name, .nftsCount]) {
						viewModel?.didUserDo(request: .selectSortBy($0))
					}
				self?.router.present(alert)

			case .selectCollection(let collection):
				self?.pushCollection(collection)
			}
		}

		router.setRootModule(module)
	}

	func pushCollection(_ collection: Collection) {
		let viewModel = container.makeCollectionViewModel(collection: collection)
		let module = factory.makeCollectionViewController(viewModel: viewModel)

		viewModel.didSendEventClosure = { [weak self, weak viewModel] event in
			switch event {

			case .showErrorAlert(let message, let withRetry):
				self?.presentErrorAlert(message: message, withRetry: withRetry) {
					viewModel?.didUserDo(request: .retryAction)
				}

			case .close:
				self?.router.popModule()

			case .showAuthorSite(let url):
				if let url = url {
					self?.pushWebViewVC(url: url)
				} else {
					self?.presentErrorAlert(message: Theme.Author.incorrectURL)
				}
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
		let dep = DefaultWebViewModel.Dependencies(url: url)
		let viewModel = DefaultWebViewModel(dep: dep)
		let module = factory.makeWebViewController(viewModel: viewModel)
		viewModel.didSendEventClosure = { [weak self] event in
			switch event {
			case .close:
				self?.router.popModule()
			}
		}

		router.push(module)
	}
}
