import Foundation

// переходы
enum CatalogEvents {
	case showErrorAlert(String)
	case showSortAlert
	case selectCollection(Collection)
}

// действия пользователя
enum CatalogRequest {
	case selectSort
	case selectSortBy(SortCollectionsBy)
	case selectItemAtIndex(Int)
}

// переходы, обработка действий пользователя, начальное состояние
protocol CatalogViewModelInput: AnyObject {
	var didSendEventClosure: ((CatalogEvents) -> Void)? { get set }

	func viewIsReady()
	func didUserDo(request: CatalogRequest)
}

// дата сорс и свойства для наблюдений
protocol CatalogViewModelOutput: AnyObject {
	var items: Observable<[Collection]> { get }
	var numberOfItems: Int { get }
	var isEmpty: Bool { get }
	var cellModels: [ICellViewAnyModel.Type] { get }

	func cellModelAtIndex(_ index: Int) -> ICellViewAnyModel
}

typealias CatalogViewModel = (
	CatalogViewModelInput &
	CatalogViewModelOutput
)

final class DefaultCatalogViewModel: CatalogViewModel {
	struct Dependencies {
		let getCollections: GetCollectionsUseCase
		let getSetSortOption: SortCollectionsOption
	}
	private let dependencies: Dependencies

	// MARK: - INPUT
	var didSendEventClosure: ((CatalogEvents) -> Void)?

	// MARK: - OUTPUT
	var items: Observable<[Collection]> = Observable([])
	var numberOfItems: Int { items.value.count }
	var isEmpty: Bool { items.value.isEmpty }
	var cellModels: [ICellViewAnyModel.Type] = [CollectionItemCellModel.self]

	// MARK: - Inits

	init(dep: Dependencies) {
		dependencies = dep
	}
}

// MARK: - OUTPUT

extension DefaultCatalogViewModel {
	func cellModelAtIndex(_ index: Int) -> ICellViewAnyModel {
		let item = items.value[index]

		return CollectionItemCellModel(
			imageURL: item.cover,
			description: "\(item.name) (\(item.nftsCount))"
		)
	}
}

// MARK: - INPUT. View event methods

extension DefaultCatalogViewModel {
	func viewIsReady() {
		dependencies.getCollections.invoke { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let collections):
				self.items.value = collections
				self.sortCollections()
			case .failure(let error):
				self.items.value = []
				self.didSendEventClosure?(.showErrorAlert(error.description))
			}
		}
	}

	func didUserDo(request: CatalogRequest) {
		switch request {
		case .selectSort:
			guard items.value.count > 1 else { return }
			didSendEventClosure?(.showSortAlert)
		case .selectSortBy(let sortBy):
			dependencies.getSetSortOption.setOption(sortBy)
			sortCollections()
		case .selectItemAtIndex(let index):
			let collection = items.value[index]
			didSendEventClosure?(.selectCollection(collection))
		}
	}
}

private extension DefaultCatalogViewModel {
	func sortCollections() {
		let sortBy = dependencies.getSetSortOption.sortBy
		switch sortBy {
		case .name:
			items.value = items.value.sorted { $0.name < $1.name }
		case .nftsCount:
			items.value = items.value.sorted { $0.nftsCount > $1.nftsCount }
		}
	}
}
