enum SortCollectionsBy: String {
	case name
	case nftsCount
}

extension SortCollectionsBy: CustomStringConvertible {
	var description: String {
		switch self {
		case .name:
			return L10n.SortByTitle.name
		case .nftsCount:
			return L10n.SortByTitle.nftsCount
		}
	}
}
