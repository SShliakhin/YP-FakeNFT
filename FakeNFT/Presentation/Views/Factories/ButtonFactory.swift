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

	static func makeLabelButton(
		label: UILabel,
		backgroundColor: UIColor = .clear,
		cornerRadius: CGFloat = .zero,
		type: UIButton.ButtonType = .custom,
		event: (() -> Void)? = nil
	) -> UIButton {
		let button = UIButton(type: type)

		button.setTitle(label.text, for: .normal)
		button.setTitleColor(label.textColor, for: .normal)
		button.titleLabel?.font = label.font
		button.titleLabel?.numberOfLines = label.numberOfLines
		button.titleLabel?.textAlignment = label.textAlignment

		button.backgroundColor = backgroundColor
		button.layer.cornerRadius = cornerRadius

		button.event = event

		return button
	}
}
