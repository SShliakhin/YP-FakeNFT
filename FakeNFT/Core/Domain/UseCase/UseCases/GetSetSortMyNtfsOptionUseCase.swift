protocol SortMyNtfsOptionOut {
	var sortBy: SortMyNftsBy { get }
}

protocol SortMyNtfsOptionIn {
	func setOption(_ kind: SortMyNftsBy)
}

final class GetSetSortMyNtfsOptionUseCase {
	@UserDefaultsBacked(key: "myNtfs-sort-option")
	private var sortOption = "rating"
}

// MARK: - SortMyNtfsOptionOut
extension GetSetSortMyNtfsOptionUseCase: SortMyNtfsOptionOut {
	var sortBy: SortMyNftsBy {
		guard let kind: SortMyNftsBy = .init(rawValue: sortOption) else {
			return .name
		}
		return kind
	}
}

// MARK: - SortMyNtfsOptionIn
extension GetSetSortMyNtfsOptionUseCase: SortMyNtfsOptionIn {
	func setOption(_ kind: SortMyNftsBy) {
		sortOption = kind.rawValue
	}
}

typealias SortMyNtfsOption = SortMyNtfsOptionOut & SortMyNtfsOptionIn
