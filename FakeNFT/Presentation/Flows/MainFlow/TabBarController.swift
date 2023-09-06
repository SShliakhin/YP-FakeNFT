import UIKit

final class TabBarController: UITabBarController {
	private let pages: [TabbarPage]
	private let firstPage: TabbarPage

	// MARK: - Inits

	init(pages: [TabbarPage], firstPage: TabbarPage) {
		self.pages = pages
		self.firstPage = firstPage
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - LifeCycle
	override func viewDidLoad() {
		super.viewDidLoad()

		setup()
	}
}

private extension TabBarController {
	func setup() {
		let controllers: [UINavigationController] = pages.map { getTabController($0) }

		setViewControllers(controllers, animated: true)
		selectedIndex = firstPage.pageOrderNumber()
	}

	func getTabController(_ page: TabbarPage) -> UINavigationController {
		let navController = UINavigationController()

		navController.tabBarItem = UITabBarItem(
			title: page.pageTitleValue(),
			image: page.pageIconValue(),
			tag: page.pageOrderNumber()
		)

		return navController
	}
}
