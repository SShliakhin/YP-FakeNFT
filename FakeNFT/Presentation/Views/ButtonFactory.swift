import UIKit

enum ButtonFactory {
	static func makeButton(
		image: UIImage,
		tintColor: UIColor = Theme.color(usage: .black),
		type: UIButton.ButtonType = .custom,
		event: (() -> Void)? = nil
	) -> UIButton {
		let button = UIButton(type: type)
		button.setImage(image, for: .normal)
		button.tintColor = tintColor
		button.event = event

		return button
	}

	static func makeTextButton(
		textFont: UIFont,
		textColor: UIColor = Theme.color(usage: .main),
		type: UIButton.ButtonType = .custom,
		event: (() -> Void)? = nil
	) -> UIButton {
		let button = UIButton(type: type)
		button.titleLabel?.font = textFont
		button.setTitleColor(textColor, for: .normal)
		button.event = event

		return button
	}
}
