protocol SortCollectionsOptionOut {
	var sortBy: SortCollectionsBy { get }
}

protocol SortCollectionsOptionIn {
	func setOption(_ kind: SortCollectionsBy)
}

final class GetSetSortCollectionsOptionUseCase {
	@UserDefaultsBacked(key: "collections-sort-option")
	private var sortOption = "name"
}

// MARK: - SortCollectionsStateOut
extension GetSetSortCollectionsOptionUseCase: SortCollectionsOptionOut {
	var sortBy: SortCollectionsBy {
		guard let kind: SortCollectionsBy = .init(rawValue: sortOption) else {
			return .name
		}
		return kind
	}
}

// MARK: - SortCollectionsStateIn
extension GetSetSortCollectionsOptionUseCase: SortCollectionsOptionIn {
	func setOption(_ kind: SortCollectionsBy) {
		sortOption = kind.rawValue
	}
}

typealias SortCollectionsOption = SortCollectionsOptionOut & SortCollectionsOptionIn
