import UIKit

extension UIViewController {
	func hideNavTabBars(_ animated: Bool) {
		navigationController?.setNavigationBarHidden(true, animated: animated)
		tabBarController?.tabBar.isHidden = true
		extendedLayoutIncludesOpaqueBars = true
	}

	func showNavTabBars(_ animated: Bool) {
		navigationController?.setNavigationBarHidden(false, animated: animated)
		tabBarController?.tabBar.isHidden = false
		extendedLayoutIncludesOpaqueBars = false
	}
}
