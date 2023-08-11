import Foundation

// переходы
enum CatalogEvents {
	case showSortAlert
	case selectCollection(String)
}

// действия пользователя
enum CatalogRequest {
	case selectSort
	case selectSortBy(SortBy)
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
	var items: Observable<[CollectionItemViewModel]> { get }
	var numberOfItems: Int { get }
	var isEmpty: Bool { get }

	func cellModelAtIndex(_ index: Int) -> CollectionItemCellModel
}

typealias CatalogViewModel = (
	CatalogViewModelInput &
	CatalogViewModelOutput
)

final class DefaultCatalogViewModel: CatalogViewModel {
	struct Dependencies {} // TODO: для зависимостей
	private let dependencies: Dependencies

	// MARK: - INPUT
	var didSendEventClosure: ((CatalogEvents) -> Void)?

	// MARK: - OUTPUT
	var items: Observable<[CollectionItemViewModel]> = Observable([])
	var numberOfItems: Int { items.value.count }
	var isEmpty: Bool { items.value.isEmpty }

	// MARK: - Inits

	init(dep: Dependencies) {
		dependencies = dep
	}
}

// MARK: - OUTPUT

extension DefaultCatalogViewModel {
	func cellModelAtIndex(_ index: Int) -> CollectionItemCellModel {
		let item = items.value[index]

		return CollectionItemCellModel(
			image: item.id, // TODO: заменить на URL в cover
			description: item.description
		)
	}
}

// MARK: - INPUT. View event methods

extension DefaultCatalogViewModel {
	func viewIsReady() {
		// TODO: - сходить в сеть и получить коллекции
		items.value = CollectionItemCellModel.mainCollections
	}

	func didUserDo(request: CatalogRequest) {
		switch request {
		case .selectSort:
			didSendEventClosure?(.showSortAlert)
		case .selectSortBy(let sortBy):
			sortCollectionsBy(sortBy)
		case .selectItemAtIndex(let index):
			let collection = items.value[index]
			didSendEventClosure?(.selectCollection(collection.id))
			print("Показать детали коллекции: \(collection.title)")
		}
	}
}

private extension DefaultCatalogViewModel {
	func sortCollectionsBy(_ sortBy: SortBy) {
		switch sortBy {
		case .name:
			items.value = items.value.sorted { $0.title < $1.title }
		case .nftsCount:
			items.value = items.value.sorted { $0.nftsCount < $1.nftsCount }
		}
	}
}
