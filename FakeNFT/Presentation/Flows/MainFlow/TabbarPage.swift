import UIKit

enum TabbarPage {
	case profile
	case catalog
	case shoppingCart
	case statistics

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

	static let allTabbarPages: [TabbarPage] = [.profile, .catalog, .shoppingCart, .statistics]
	static let firstTabbarPage: TabbarPage = .shoppingCart

	var pageOrderNumber: Int {
		guard let num = TabbarPage.allTabbarPages.firstIndex(of: self) else { return .zero }
		return num
	}
}
