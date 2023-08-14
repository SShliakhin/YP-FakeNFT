import UIKit

enum TabbarPage: Int {
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
			return Appearance.profileTabTitle
		case .catalog:
			return Appearance.catalogTabTitle
		case .shoppingCart:
			return Appearance.shoppingCartTabTitle
		case .statistics:
			return Appearance.statisticsTabTitle
		}
	}
	func pageIconValue() -> UIImage {
		switch self {
		case .profile:
			return Appearance.tabProfileIcon
		case .catalog:
			return Appearance.tabCatalogIcon
		case .shoppingCart:
			return Appearance.tabShoppingCartIcon
		case .statistics:
			return Appearance.tabStatsIcon
		}
	}
	func pageFlow() -> IFlow {
		switch self {
		case .profile:
			return ProfileFlow()
		case .catalog:
			return CatalogFlow()
		case .shoppingCart:
			return ShoppingCartFlow()
		case .statistics:
			return StatisticsFlow()
		}
	}
}

private extension TabbarPage {

	enum Appearance {
		static let profileTabTitle = "Профиль"
		static let catalogTabTitle = "Каталог"
		static let shoppingCartTabTitle = "Корзина"
		static let statisticsTabTitle = "Статистика"

		static let tabProfileIcon = Theme.image(kind: .profileIcon)
		static let tabCatalogIcon = Theme.image(kind: .catalogIcon)
		static let tabShoppingCartIcon = Theme.image(kind: .bagIcon)
		static let tabStatsIcon = Theme.image(kind: .statisticsIcon)
	}
}
