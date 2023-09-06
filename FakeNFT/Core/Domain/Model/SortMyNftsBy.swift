enum SortMyNftsBy: String {
	case name
	case price
	case rating
}

extension SortMyNftsBy: CustomStringConvertible {
	var description: String {
		switch self {
		case .name:
			return L10n.SortByTitle.name
		case .price:
			return L10n.SortByTitle.price
		case .rating:
			return L10n.SortByTitle.rating
		}
	}
}
