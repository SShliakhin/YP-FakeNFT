import UIKit

protocol ILoadWithIndicator: AnyObject {
	var activityIndicator: UIActivityIndicatorView { get }

	func startIndicator()
	func stopIndicator()
}

extension ILoadWithIndicator {
	var window: UIWindow? {
		return UIApplication.shared.windows.first
	}

	func startIndicator() {
		window?.isUserInteractionEnabled = false
		self.activityIndicator.startAnimating()
	}

	func stopIndicator() {
		window?.isUserInteractionEnabled = true
		self.activityIndicator.stopAnimating()
	}
}
