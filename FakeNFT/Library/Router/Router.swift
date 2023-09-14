import UIKit

protocol Presentable {
	func toPresent() -> UIViewController?
}

extension UIViewController: Presentable {
	func toPresent() -> UIViewController? { self }
}

protocol Router: UIAdaptivePresentationControllerDelegate, Presentable {

	func present(_ module: Presentable?)
	func present(_ module: Presentable?, animated: Bool)
	func present(_ module: Presentable?, animated: Bool, onDismiss: (() -> Void)?)

	func push(_ module: Presentable?)
	func push(_ module: Presentable?, hideBottomBar: Bool)
	func push(_ module: Presentable?, animated: Bool)
	func push(_ module: Presentable?, animated: Bool, completion: (() -> Void)?)
	func push(_ module: Presentable?, animated: Bool, hideBottomBar: Bool, completion: (() -> Void)?)

	func popModule()
	func popModule(animated: Bool)

	func dismissModule()
	func dismissModule(animated: Bool, completion: (() -> Void)?)

	func setRootModule(_ module: Presentable?)
	func setRootModule(_ module: Presentable?, hideBar: Bool)

	func popToRootModule(animated: Bool)
}
