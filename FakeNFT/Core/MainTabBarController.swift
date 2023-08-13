import UIKit

final class MainTabBarController: UITabBarController {
	private lazy var pages: [TabbarPage] = {
		[
			.profile,
			.catalog,
			.shoppingCart,
			.statistics
		].sorted(by: { $0.pageOrderNumber() < $1.pageOrderNumber() })
	}()
	private let firstPage: TabbarPage = .shoppingCart

	override func viewDidLoad() {
		super.viewDidLoad()

		setup()
	}
}

private extension MainTabBarController {
	func setup() {
		let controllers: [UINavigationController] = pages.map { getTabController($0) }

		setViewControllers(controllers, animated: true)
		selectedIndex = firstPage.pageOrderNumber()
	}

	func getTabController(_ page: TabbarPage) -> UINavigationController {
		let navController = UINavigationController(
			rootViewController: page.pageFlow().start()
		)

		navController.tabBarItem = UITabBarItem(
			title: page.pageTitleValue(),
			image: page.pageIconValue(),
			tag: page.pageOrderNumber()
		)

		return navController
	}
}
