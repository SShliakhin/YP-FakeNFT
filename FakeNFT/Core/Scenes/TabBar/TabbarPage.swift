import UIKit

enum TabbarPage {
	case profile(ProfileFlowDIContainer)
	case catalog(CatalogFlowDIContainer)
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
			return Theme.TabTitle.profile
		case .catalog:
			return Theme.TabTitle.catalog
		case .shoppingCart:
			return Theme.TabTitle.cart
		case .statistics:
			return Theme.TabTitle.stats
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
	func pageFlow() -> IFlow {
		switch self {
		case .profile(let container):
			return ProfileFlow(
				profileModuleFactory: ModuleFactoryImp(),
				profileDIContainer: container
			)
		case .catalog(let container):
			return CatalogFlow(
				catalogModuleFactory: ModuleFactoryImp(),
				catalogDIContainer: container
			)
		case .shoppingCart:
			return ShoppingCartFlow()
		case .statistics:
			return StatisticsFlow()
		}
	}
}
