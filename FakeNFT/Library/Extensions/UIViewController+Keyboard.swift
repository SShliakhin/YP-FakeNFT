import UIKit

extension UIViewController {
	func setupDismissKeyboardGesture() {
		let dismissKeyboardTap = UITapGestureRecognizer(
			target: self,
			action: #selector(viewTapped(_: ))
		)
		view.addGestureRecognizer(dismissKeyboardTap)
	}

	func setupKeyboardHiding() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillShow),
			name: UIResponder.keyboardWillShowNotification,
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillHide),
			name: UIResponder.keyboardWillHideNotification,
			object: nil
		)
	}

	@objc func viewTapped(_ recognizer: UITapGestureRecognizer) {
		view.endEditing(true) // resign first responder
	}

	@objc func keyboardWillShow(sender: NSNotification) {
		guard let userInfo = sender.userInfo,
			  let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
			  UIResponder.currentFirst() is UITextField ||
				UIResponder.currentFirst() is UITextView,
			  let responderView = UIResponder.currentFirst() as? UIView
		else { return }

		let keyboardTopY = keyboardFrame.cgRectValue.origin.y
		let convertedResponderViewFrame = view.convert(
			responderView.frame,
			from: responderView.superview
		)
		let textBoxY = convertedResponderViewFrame.origin.y

		// почему то у TextView неверно определяется bottom
		// let responderViewBottomY = textBoxY + convertedResponderViewFrame.size.height
		// убрал проверку, чтобы VC всегда подымался
		// if responderViewBottomY > keyboardTopY {
		let newFrameY = (textBoxY - keyboardTopY / 2) * -1
		view.frame.origin.y = newFrameY
		// }
	}

	@objc func keyboardWillHide(notification: NSNotification) {
		view.frame.origin.y = 0
	}
}
