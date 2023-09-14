import UIKit

enum LabelFactory {
	static func makeLabel(
		font: UIFont,
		text: String = "",
		textColor: UIColor = Theme.color(usage: .main),
		numberOfLines: Int = 1,
		textAligment: NSTextAlignment = .left,
		tap: UITapGestureRecognizer? = nil
	) -> UILabel {
		let label = UILabel()
		label.font = font
		label.text = text
		label.textColor = textColor
		label.numberOfLines = numberOfLines
		label.textAlignment = textAligment
		if let tap = tap {
			label.addGestureRecognizer(tap)
			label.isUserInteractionEnabled = true
		}

		return label
	}

	static func makeTapLabel(tap: UITapGestureRecognizer) -> UILabel {
		let label = UILabel()
		label.addGestureRecognizer(tap)
		label.isUserInteractionEnabled = true

		return label
	}
}
