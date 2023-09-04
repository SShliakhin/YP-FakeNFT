import UIKit

struct CatalogFlow: IFlow {
	let catalogModuleFactory: CatalogModuleFactory
	let catalogDIContainer: CatalogFlowDIContainer

	func start() -> UIViewController {
		showCatalogOfCollections()
	}

	func showCatalogOfCollections() -> UIViewController {
		let viewModel = catalogDIContainer.makeCatalogViewModel()
		let view = catalogModuleFactory.makeCatalogViewController(viewModel: viewModel)
		viewModel.didSendEventClosure = { [weak view, weak viewModel] event in
			switch event {
			case .showErrorAlert(let message):
				let alert = catalogModuleFactory.makeErrorAlertVC(message: message) { viewModel?.didUserDo(request: .retryAction)
				}
				view?.present(alert, animated: true)
			case .showSortAlert:
				let alert = catalogModuleFactory.makeSortAlertVC(sortCases: [.name, .nftsCount]) {
					viewModel?.didUserDo(request: .selectSortBy($0))
				}
				view?.present(alert, animated: true)
			case .selectCollection(let collection):
				let collectionVC = makeCollectionVCBy(collection: collection)
				view?.show(collectionVC, sender: view)
			}
		}

		return view
	}

	func makeCollectionVCBy(collection: Collection) -> UIViewController {
		let viewModel = catalogDIContainer.makeCollectionViewModel(collection: collection)
		let view = catalogModuleFactory.makeCollectionViewController(viewModel: viewModel)
		viewModel.didSendEventClosure = { [weak view, weak viewModel] event in
			switch event {
			case .showErrorAlert(let message, let withRetry):
				let alert = makeErrorAlert(message: message, withRetry: withRetry) {
					viewModel?.didUserDo(request: .retryAction)
				}
				view?.present(alert, animated: true)
			case .close:
				view?.navigationController?.popViewController(animated: true)
			case .showAuthorSite(let url):
				if let url = url {
					let webViewVC = makeWebViewVC(url: url)
					view?.show(webViewVC, sender: view)
				} else {
					let alert = catalogModuleFactory.makeErrorAlertVC(
						message: Theme.Author.incorrectURL,
						completion: nil
					)
					view?.present(alert, animated: true)
				}
			}
		}

		return view
	}

	func makeWebViewVC(url: URL) -> UIViewController {
		let dep = DefaultWebViewModel.Dependencies(url: url)
		let viewModel = DefaultWebViewModel(dep: dep)
		let view = catalogModuleFactory.makeWebViewController(viewModel: viewModel)
		viewModel.didSendEventClosure = { [weak view] event in
			switch event {
			case .close:
				view?.navigationController?.popViewController(animated: true)
			}
		}

		return view
	}

	func makeErrorAlert(message: String, withRetry: Bool, completion: (() -> Void)?) -> UIViewController {
		catalogModuleFactory.makeErrorAlertVC(
			message: message,
			completion: withRetry ? completion : nil
		)
	}
}
