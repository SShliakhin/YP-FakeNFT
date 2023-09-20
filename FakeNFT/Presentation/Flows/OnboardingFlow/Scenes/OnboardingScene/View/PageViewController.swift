import UIKit

protocol PageViewController: UIViewController {
	var onShowPage: ((Int) -> Void)? { get }
	func update(pageNumber: Int)
}

final class PageViewControllerImp: UIPageViewController, PageViewController {

	private var pages: [UIViewController]
	private var currentIndex: Int {
		if
			let first = viewControllers?.first,
			let index = pages.firstIndex(of: first) {
			return index
		}
		return .zero
	}

	var onShowPage: ((Int) -> Void)?

	// MARK: - Inits -

	init(
		pages: [UIViewController],
		onShowPage: ((Int) -> Void)? = nil
	) {
		self.pages = pages
		self.onShowPage = onShowPage

		super.init(
			transitionStyle: .scroll,
			navigationOrientation: .horizontal,
			options: [:]
		)

		dataSource = self
		delegate = self

		if let firstViewController = pages.first {
			setViewControllers(
				[firstViewController],
				direction: .forward,
				animated: true,
				completion: nil
			)
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("PageViewController deinit")
	}
}

// MARK: - UIPageViewControllerDataSource -

extension PageViewControllerImp: UIPageViewControllerDataSource {
	func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerBefore viewController: UIViewController
	) -> UIViewController? {
		guard let currentPageIndex = pages.firstIndex(of: viewController) else {
			return nil
		}

		let previousIndex = currentPageIndex - 1
		guard
			previousIndex >= 0,
			pages.count > previousIndex
		else {
			return nil
		}

		return pages[previousIndex]
	}

	func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerAfter viewController: UIViewController
	) -> UIViewController? {
		guard let currentPageIndex = pages.firstIndex(of: viewController) else {
			return nil
		}

		let nextIndex = currentPageIndex + 1
		guard pages.count > nextIndex else {
			return nil
		}

		return pages[nextIndex]
	}
}

// MARK: - UIPageViewControllerDelegate -

extension PageViewControllerImp: UIPageViewControllerDelegate {
	func pageViewController(
		_ pageViewController: UIPageViewController,
		didFinishAnimating: Bool,
		previousViewControllers: [UIViewController],
		transitionCompleted: Bool
	) {
		onShowPage?(currentIndex)
	}
}

// MARK: - PageViewController -

extension PageViewControllerImp {
	func update(pageNumber: Int) {
		guard pageNumber < pages.count else { return }

		setViewControllers(
			[pages[pageNumber]],
			direction: pageNumber > currentIndex ? .forward : .reverse,
			animated: true,
			completion: nil
		)
	}
}
