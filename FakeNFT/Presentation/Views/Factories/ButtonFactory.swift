import UIKit

enum ButtonFactory {
	static func makeButton(
		image: UIImage,
		tintColor: UIColor = Theme.color(usage: .black),
		event: (() -> Void)? = nil
	) -> UIButton {
		let button = UIButton(type: .custom)
		button.setImage(image, for: .normal)
		button.tintColor = tintColor
		button.event = event

		return button
	}

	static func makeLabelButton(
		label: UILabel? = nil,
		backgroundColor: UIColor = .clear,
		cornerRadius: CGFloat = .zero,
		event: (() -> Void)? = nil
	) -> UIButton {
		let button = UIButton(type: .custom)

		if let label = label {
			button.setTitle(label.text, for: .normal)
			button.setTitleColor(label.textColor, for: .normal)
			button.titleLabel?.font = label.font
			button.titleLabel?.numberOfLines = label.numberOfLines
			button.titleLabel?.textAlignment = label.textAlignment
		}

		button.backgroundColor = backgroundColor
		button.layer.cornerRadius = cornerRadius

		button.event = event

		return button
	}
}
