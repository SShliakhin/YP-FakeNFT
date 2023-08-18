protocol SortMyNtfsOptionOut {
	var sortBy: SortMyNtfsBy { get }
}

protocol SortMyNtfsOptionIn {
	func setOption(_ kind: SortMyNtfsBy)
}

final class GetSetSortMyNtfsOptionUseCase {
	@UserDefaultsBacked(key: "myNtfs-sort-option")
	private var sortOption = "rating"
}

// MARK: - SortMyNtfsOptionOut
extension GetSetSortMyNtfsOptionUseCase: SortMyNtfsOptionOut {
	var sortBy: SortMyNtfsBy {
		guard let kind: SortMyNtfsBy = .init(rawValue: sortOption) else {
			return .name
		}
		return kind
	}
}

// MARK: - SortMyNtfsOptionIn
extension GetSetSortMyNtfsOptionUseCase: SortMyNtfsOptionIn {
	func setOption(_ kind: SortMyNtfsBy) {
		sortOption = kind.rawValue
	}
}

typealias SortMyNtfsOption = SortMyNtfsOptionOut & SortMyNtfsOptionIn
