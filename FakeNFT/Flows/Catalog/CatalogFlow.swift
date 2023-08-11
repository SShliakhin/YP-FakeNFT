import UIKit

struct CatalogFlow: IFlow {
	func start() -> UIViewController {
		showCatalogOfCollections()
	}

	func showCatalogOfCollections() -> UIViewController {
		let dep = DefaultCatalogViewModel.Dependencies()
		let viewModel = DefaultCatalogViewModel(dep: dep)
		let view = CatalogViewController(viewModel: viewModel)
		viewModel.didSendEventClosure = { [weak view, viewModel] event in
			switch event {
			case .showSortAlert:
				let alert = makeSortAlertVC(
					sortCases: [.name, .nftsCount],
					completion: { viewModel.didUserDo(request: .selectSortBy($0)) }
				)
				view?.present(alert, animated: true)
			case .selectCollection(let index):
				let collectionVC = makeCollectionVCBy(index: index)
				view?.show(collectionVC, sender: view)
			}
		}

		return view
	}

	func makeCollectionVCBy(index: String) -> UIViewController {
		let view = ShoppingCartViewController()

		return view
	}

	func makeSortAlertVC(sortCases: [SortBy], completion: @escaping (SortBy) -> Void) -> UIViewController {
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
}

private extension CatalogFlow {
	enum Appearance {
		static let alertTitle = "Сортировка"
		static let actionCloseTitle = "Закрыть"
	}
}
