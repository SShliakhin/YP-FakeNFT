enum SortCollectionsBy: String {
	case name
	case nftsCount
}

extension SortCollectionsBy: CustomStringConvertible {
	var description: String {
		switch self {
		case .name:
			return Appearance.sortByName
		case .nftsCount:
			return Appearance.sortByNftsCount
		}
	}
}

private extension SortCollectionsBy {
	enum Appearance {
		static let sortByName = "По названию"
		static let sortByNftsCount = "По количеству NFT"
	}
}
