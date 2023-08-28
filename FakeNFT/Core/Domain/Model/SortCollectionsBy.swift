enum SortCollectionsBy: String {
	case name
	case nftsCount
}

extension SortCollectionsBy: CustomStringConvertible {
	var description: String {
		switch self {
		case .name:
			return Theme.SortByTitle.name
		case .nftsCount:
			return Theme.SortByTitle.nftsCount
		}
	}
}
