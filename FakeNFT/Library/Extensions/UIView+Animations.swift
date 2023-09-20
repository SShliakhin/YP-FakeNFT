import UIKit

extension UIView {
	func fadeIn(_ duration: TimeInterval = 0.2) {
		alpha = 0
		isHidden = false
		UIView.animate(withDuration: duration) { [weak self] in
			self?.alpha = 1
		}
	}

	func fadeOut(_ duration: TimeInterval = 0.2) {
		UIView.animate(withDuration: duration) { [weak self] in
			self?.alpha = 0
		} completion: { [weak self] _ in
			self?.isHidden = true
		}
	}

	func addClickAnimation() {
		let xScale: CGFloat = 1.025
		let yScale: CGFloat = 1.05

		UIView.animate(
			withDuration: 0.1,
			animations: {
				let transformation = CGAffineTransform(scaleX: xScale, y: yScale)
				self.transform = transformation
			},
			completion: { _ in
				let transformation = CGAffineTransform(scaleX: 1, y: 1)
				self.transform = transformation
			}
		)
	}
}
