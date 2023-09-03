import UIKit

struct CatalogFlow: IFlow {
	private let catalogModuleFactory: CatalogModuleFactory = ModuleFactoryImp()

	func start() -> UIViewController {
		showCatalogOfCollections()
	}

	func showCatalogOfCollections() -> UIViewController {
		let dep = DefaultCatalogViewModel.Dependencies(
			getCollections: UseCaseProvider.instance.getCollections,
			getSetSortOption: UseCaseProvider.instance.getSetSortCollectionsOption
		)
		let viewModel = DefaultCatalogViewModel(dep: dep)
		let view = catalogModuleFactory.makeCatalogViewController(viewModel: viewModel)
		viewModel.didSendEventClosure = { [weak view, weak viewModel] event in
			switch event {
			case .showErrorAlert(let message):
				let alert = catalogModuleFactory.makeErrorAlertVC(
					message: message,
					completion: { viewModel?.didUserDo(request: .retryAction) }
				)
				view?.present(alert, animated: true)
			case .showSortAlert:
				let alert = catalogModuleFactory.makeSortAlertVC(
					sortCases: [.name, .nftsCount],
					completion: { viewModel?.didUserDo(request: .selectSortBy($0)) }
				)
				view?.present(alert, animated: true)
			case .selectCollection(let collection):
				let collectionVC = makeCollectionVCBy(collection: collection)
				view?.show(collectionVC, sender: view)
			}
		}

		return view
	}

	func makeCollectionVCBy(collection: Collection) -> UIViewController {
		let dep = DefaultCollectionViewModel.Dependencies(
			collection: collection,
			getAuthor: UseCaseProvider.instance.getAuthors,
			getNfts: UseCaseProvider.instance.getNfts,
			getLikes: UseCaseProvider.instance.getLikes,
			putLikes: UseCaseProvider.instance.putLikes,
			getOrder: UseCaseProvider.instance.getOrder,
			putOrder: UseCaseProvider.instance.putOrder
		)
		let viewModel = DefaultCollectionViewModel(dep: dep)
		let view = catalogModuleFactory.makeCollectionViewController(viewModel: viewModel)
		viewModel.didSendEventClosure = { [weak view, weak viewModel] event in
			switch event {
			case .showErrorAlert(let message, let withRetry):
				let alert = catalogModuleFactory.makeErrorAlertVC(
					message: message,
					completion: withRetry
					? { viewModel?.didUserDo(request: .retryAction) }
					: nil
				)
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
}
