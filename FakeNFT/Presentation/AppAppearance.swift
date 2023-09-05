import UIKit

enum AppAppearance {

	static func setupAppearance() {
		if #available(iOS 15, *) {
			let appearance = UINavigationBarAppearance()
			appearance.configureWithTransparentBackground()
			appearance.backgroundColor = Theme.color(usage: .white)
			UINavigationBar.appearance().standardAppearance = appearance
			UINavigationBar.appearance().scrollEdgeAppearance = appearance
		} else {
			UINavigationBar.appearance().backgroundColor = Theme.color(usage: .white)
		}

		let titleTextAttributes = [
			NSAttributedString.Key.font: Theme.font(style: .caption),
			NSAttributedString.Key.foregroundColor: Theme.color(usage: .main)
		]

		let tabBarItemsAppearance = UITabBarItemAppearance()
		tabBarItemsAppearance.normal.titleTextAttributes = titleTextAttributes
		tabBarItemsAppearance.normal.iconColor = Theme.color(usage: .black)

		let tabBarAppearance = UITabBarAppearance()
		tabBarAppearance.backgroundColor = Theme.color(usage: .white)
		tabBarAppearance.stackedLayoutAppearance = tabBarItemsAppearance

		UITabBar.appearance().standardAppearance = tabBarAppearance

		if #available(iOS 15.0, *) {
			UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
		}

		UITabBar.appearance().tintColor = Theme.color(usage: .accent)

		UITabBar.appearance().isTranslucent = false
		UITabBar.appearance().clipsToBounds = true
	}
}

extension UINavigationController {
	@objc open override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
}
