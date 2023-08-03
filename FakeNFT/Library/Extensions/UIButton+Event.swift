import UIKit

// MARK: - Button event
extension UIButton {
	private enum AssociatedKeys {
		static var event = "event"
	}

	var event: (() -> Void)? {
		get {
			return objc_getAssociatedObject(self, &AssociatedKeys.event) as? () -> Void
		}
		set {
			objc_setAssociatedObject(self, &AssociatedKeys.event, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
		}
	}

	@objc private func onButtonTapped() {
		event?()
	}
}
