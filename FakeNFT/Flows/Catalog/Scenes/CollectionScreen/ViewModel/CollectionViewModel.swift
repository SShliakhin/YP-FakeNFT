import Foundation

enum CollectionSection {
	case header(Author)
	case list([Nft])

	var rowCount: Int {
		switch self {
		case .header:
			return 1 // swiftlint:disable:this numbers_smell
		case .list(let list):
			return list.count
		}
	}
}

// переходы
enum CollectionEvents {
	case close
	case showAuthorSite(URL?)
}

// действия пользователя
enum CollectionRequest {
	case goBack
}

// переходы, обработка действий пользователя, начальное состояние
protocol CollectionViewModelInput: AnyObject {
	var didSendEventClosure: ((CollectionEvents) -> Void)? { get set }

	func viewIsReady()
	func didUserDo(request: CollectionRequest)
}

// дата сорс и свойства для наблюдений
protocol CollectionViewModelOutput: AnyObject {
	var dataSource: Observable<[CollectionSection]> { get }
	var likes: Observable<[String]> { get }
	var order: Observable<[String]> { get }
	var numberOfSection: Int { get }
	var cellModels: [ICellViewAnyModel.Type] { get }

	func numberOfItemInSection(_ index: Int) -> Int
	func cellModelInSectionAtIndex(section: Int, index: Int) -> ICellViewAnyModel
}

typealias CollectionViewModel = (
	CollectionViewModelInput &
	CollectionViewModelOutput
)

final class DefaultCollectionViewModel: CollectionViewModel {
	struct Dependencies {
		let collection: Collection
	} // TODO: для зависимостей
	private let dependencies: Dependencies

	// MARK: - INPUT
	var didSendEventClosure: ((CollectionEvents) -> Void)?

	// MARK: - OUTPUT
	var dataSource: Observable<[CollectionSection]> = Observable([])
	var likes: Observable<[String]> = Observable([])
	var order: Observable<[String]> = Observable([])
	var numberOfSection: Int {
		dataSource.value.count
	}
	var cellModels: [ICellViewAnyModel.Type] = [NftItemCellModel.self, CollectionHeaderCellModel.self]

	// MARK: - Inits

	init(dep: Dependencies) {
		dependencies = dep
	}
}

// MARK: - OUTPUT

extension DefaultCollectionViewModel {
	func numberOfItemInSection(_ index: Int) -> Int {
		dataSource.value[index].rowCount
	}
	func cellModelInSectionAtIndex(section: Int, index: Int) -> ICellViewAnyModel {
		let section = dataSource.value[section]
		switch section {
		case .header(let author):
			return CollectionHeaderCellModel(
				coverImageString: dependencies.collection.name,
				title: dependencies.collection.name,
				author: author.name,
				description: dependencies.collection.description,
				onTapAuthor: { [weak self] in
					self?.didSendEventClosure?(.showAuthorSite(author.website))
				}
			)
		case .list(let list):
			let nft = list[index]
			return NftItemCellModel(
				avatarImageString: nft.name,
				isFavorite: likes.value.contains(nft.id),
				rating: nft.rating,
				title: nft.name,
				price: nft.price,
				isInCart: order.value.contains(nft.id),
				onTapFavorite: { [weak self] in self?.likeItemWithID(nft.id) },
				onTapInCart: { [weak self] in self?.addToCartItemWithID(nft.id) }
			)
		}
	}
}

// MARK: - INPUT. View event methods

extension DefaultCollectionViewModel {
	func viewIsReady() {
		// TODO: - заблокировать и сходить в сеть
		dataSource.value = Appearance.defaultDataSource
		likes.value = Appearance.defaultLikes
		order.value = Appearance.defaultOrder
	}

	func didUserDo(request: CollectionRequest) {
		switch request {
		case .goBack:
			didSendEventClosure?(.close)
		}
	}
}

private extension DefaultCollectionViewModel {
	func likeItemWithID(_ nftID: String) {
		if likes.value.contains(nftID) {
			likes.value.removeAll { $0 == nftID }
		} else {
			likes.value.append(nftID)
		}
		// TODO: - заблокировать, изменить локально и отправить в сеть
	}

	func addToCartItemWithID(_ nftID: String) {
		if order.value.contains(nftID) {
			order.value.removeAll { $0 == nftID }
		} else {
			order.value.append(nftID)
		}
		// TODO: - заблокировать, изменить локально и отправить в сеть
	}
}

// MARK: - Section
private extension DefaultCollectionViewModel {
	enum Appearance {
		static let defaultLikes: [String] = ["49", "51", "53"]
		static let defaultOrder: [String] = ["50", "51", "54"]
		static let defaultDataSource: [CollectionSection] =
		[
			CollectionSection.header(
				.init(
					id: "6",
					name: "Cole Edwards",
					website: URL(string: "https://practicum.yandex.ru/middle-frontend/")
				)
			),
			CollectionSection.list(
				[
					.init(
						id: "49",
						name: "Archie",
						description: "",
						rating: 5,
						images: [],
						price: 7.74
					),
					.init(
						id: "50",
						name: "Art",
						description: "",
						rating: 4,
						images: [],
						price: 0.33
					),
					.init(
						id: "51",
						name: "Biscuit",
						description: "",
						rating: 4,
						images: [],
						price: 1.59
					),
					.init(
						id: "52",
						name: "Daisy",
						description: "",
						rating: 5,
						images: [],
						price: 1.38
					),
					.init(
						id: "54",
						name: "Oreo",
						description: "",
						rating: 3,
						images: [],
						price: 7.06
					),
					.init(
						id: "53",
						name: "Nacho",
						description: "",
						rating: 2,
						images: [],
						price: 3.72
					)
				]
			)
		]
	}
}
