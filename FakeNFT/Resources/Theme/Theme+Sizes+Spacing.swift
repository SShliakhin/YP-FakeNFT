import UIKit

extension Theme {
	// MARK: - Spacing
	enum Spacing {
		case standard
		case standard2
		case standardHalf
		case standard3
		case standard4
		case standard5
		case constant20
	}

	static func spacing(usage: Spacing) -> CGFloat {
		let customSpacing: CGFloat

		switch usage {
		case .standard:
			customSpacing = 8
		case .standard2:
			customSpacing = 16
		case .standardHalf:
			customSpacing = 4
		case .standard3:
			customSpacing = 24
		case .standard4:
			customSpacing = 32
		case .standard5:
			customSpacing = 40
		case .constant20:
			customSpacing = 20
		}

		return customSpacing
	}

	// MARK: - Size
	enum Dimension {
		case cornerRadius
		case largeRadius
		case mediumRadius
		case smallRadius
		case largeHeight
		case mediumHeight
		case smallHeight
		case largeBorder
		case smallBorder
	}

	static func dimension(kind: Dimension) -> CGFloat {
		let customDimension: CGFloat

		switch kind {
		case .cornerRadius:
			customDimension = 16
		case .largeRadius:
			customDimension = 12
		case .mediumRadius:
			customDimension = 10
		case .smallRadius:
			customDimension = 8
		case .largeHeight:
			customDimension = 90
		case .mediumHeight:
			customDimension = 75
		case .smallHeight:
			customDimension = 60
		case .largeBorder:
			customDimension = 3
		case .smallBorder:
			customDimension = 1
		}

		return customDimension
	}

	enum Size {
		case small
		case medium
		case large
	}

	static func size(kind: Size) -> CGSize {
		let customSize: CGSize

		switch kind {
		case .small:
			customSize = .init(width: 24, height: 24)
		case .medium:
			customSize = .init(width: 34, height: 34)
		case .large:
			customSize = .init(width: 50, height: 50)
		}

		return customSize
	}
}
