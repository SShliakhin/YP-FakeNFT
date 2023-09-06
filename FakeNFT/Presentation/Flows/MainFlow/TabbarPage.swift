import UIKit

enum TabbarPage {
	case profile
	case catalog
	case shoppingCart
	case statistics

	func pageOrderNumber() -> Int {
		switch self {
		case .profile:
			return .zero
		case .catalog:
			return 1 // swiftlint:disable:this numbers_smell
		case .shoppingCart:
			return 2 // swiftlint:disable:this numbers_smell
		case .statistics:
			return 3 // swiftlint:disable:this numbers_smell
		}
	}
	func pageTitleValue() -> String {
		switch self {
		case .profile:
			return L10n.TabTitle.profile
		case .catalog:
			return L10n.TabTitle.catalog
		case .shoppingCart:
			return L10n.TabTitle.cart
		case .statistics:
			return L10n.TabTitle.stats
		}
	}
	func pageIconValue() -> UIImage {
		switch self {
		case .profile:
			return Theme.image(kind: .profileIcon)
		case .catalog:
			return Theme.image(kind: .catalogIcon)
		case .shoppingCart:
			return Theme.image(kind: .bagIcon)
		case .statistics:
			return Theme.image(kind: .statisticsIcon)
		}
	}
}
