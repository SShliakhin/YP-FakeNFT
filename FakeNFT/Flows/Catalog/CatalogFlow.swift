import UIKit

struct CatalogFlow: IFlow {
	func start() -> UIViewController {
		showCatalogOfCollections()
	}

	func showCatalogOfCollections() -> UIViewController {
		let dep = DefaultCatalogViewModel.Dependencies(
			getCollections: CatalogUseCaseProvider.instance.getCollections,
			getSetSortOption: CatalogUseCaseProvider.instance.getSetSortCollectionsOption
		)
		let viewModel = DefaultCatalogViewModel(dep: dep)
		let view = CatalogViewController(viewModel: viewModel)
		viewModel.didSendEventClosure = { [weak view, viewModel] event in
			switch event {
			case .showErrorAlert(let message):
				let alert = makeErrorAlertVC(message: message)
				view?.present(alert, animated: true)
			case .showSortAlert:
				let alert = makeSortAlertVC(
					sortCases: [.name, .nftsCount],
					completion: { viewModel.didUserDo(request: .selectSortBy($0)) }
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
			getAuthor: CatalogUseCaseProvider.instance.getAuthor,
			getNfts: CatalogUseCaseProvider.instance.getNfts,
			getLikes: CatalogUseCaseProvider.instance.getLikes,
			putLikes: CatalogUseCaseProvider.instance.putLikes,
			getOrder: CatalogUseCaseProvider.instance.getOrder,
			putOrder: CatalogUseCaseProvider.instance.putOrder
		)
		let viewModel = DefaultCollectionViewModel(dep: dep)
		let view = CollectionViewController(viewModel: viewModel)
		viewModel.didSendEventClosure = { [weak view] event in
			switch event {
			case .close:
				view?.navigationController?.popViewController(animated: true)
			case .showAuthorSite(let url):
				if let url = url {
					let webViewVC = makeWebViewVC(url: url)
					view?.show(webViewVC, sender: view)
				} else {
					print("url не url")
				}
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
		sortCases: [SortCollectionsBy],
		completion: @escaping (SortCollectionsBy) -> Void
	) -> UIViewController {
		let alert = UIAlertController(
			title: Appearance.alertTitle,
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
			UIAlertAction(title: Appearance.actionCloseTitle, style: .cancel)
		)

		return alert
	}

	func makeErrorAlertVC(
		message: String,
		completion: (() -> Void)? = nil
	) -> UIViewController {
		let alert = UIAlertController(
			title: Appearance.alertErrorTitle,
			message: message,
			preferredStyle: .alert
		)
		alert.addAction(
			UIAlertAction(title: Appearance.alertOK, style: .default) { _ in
				completion?()
			}
		)

		return alert
	}
}

private extension CatalogFlow {
	enum Appearance {
		static let alertTitle = "Сортировка"
		static let actionCloseTitle = "Закрыть"
		static let alertErrorTitle = "Ошибка"
		static let alertOK = "OK"
	}
}
