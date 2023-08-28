enum SortMyNftsBy: String {
	case name
	case price
	case rating
}

extension SortMyNftsBy: CustomStringConvertible {
	var description: String {
		switch self {
		case .name:
			return Theme.SortByTitle.name
		case .price:
			return Theme.SortByTitle.price
		case .rating:
			return Theme.SortByTitle.rating
		}
	}
}
