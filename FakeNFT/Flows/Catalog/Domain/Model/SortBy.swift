enum SortBy {
	case name
	case nftsCount
}

extension SortBy: CustomStringConvertible {
	var description: String {
		switch self {
		case .name:
			return Appearance.sortByName
		case .nftsCount:
			return Appearance.sortByNftsCount
		}
	}
}

private extension SortBy {
	enum Appearance {
		static let sortByName = "По названию"
		static let sortByNftsCount = "По количеству NFT"
	}
}
