import UIKit

extension Theme {
	// MARK: - Colors
	private enum FlatColor {
		static let black = UIColor(hex: 0x1A1B22)
		static let white = UIColor(hex: 0xFFFFFF)

		static let lightGrayDay = UIColor(hex: 0xF7F7F8)
		static let lightGrayNight = UIColor(hex: 0x2C2C2E)

		static let gray = UIColor(hex: 0x625C5C)
		static let red = UIColor(hex: 0xF56B6C)
		static let backround = UIColor(hex: 0x1A1B22).withAlphaComponent(0.5)
		static let green = UIColor(hex: 0x1C9F00)
		static let blue = UIColor(hex: 0x0A84FF)
		static let yellow = UIColor(hex: 0xFEEF0D)
	}

	enum Color: String {
		case main
		case accent
		case background
		case attention
		case white
		case black
		case lightGray
		case gray
		case red
		case green
		case blue
		case allDayWhite
		case allDayBlack
		case yellow
	}

	static func color(usage: Color) -> UIColor {
		let customColor: UIColor

		switch usage {
		case .main:
			customColor = UIColor.color(
				light: FlatColor.black,
				dark: FlatColor.white
			)
		case .accent:
			customColor = FlatColor.blue
		case .background:
			customColor = FlatColor.backround
		case .attention:
			customColor = FlatColor.red

		case .white:
			customColor = UIColor.color(
				light: FlatColor.white,
				dark: FlatColor.black
			)
		case .black:
			customColor = UIColor.color(
				light: FlatColor.black,
				dark: FlatColor.white
			)
		case .lightGray:
			customColor = UIColor.color(
				light: FlatColor.lightGrayDay,
				dark: FlatColor.lightGrayNight
			)

		case .gray:
			customColor = FlatColor.gray
		case .allDayWhite:
			customColor = FlatColor.white
		case .allDayBlack:
			customColor = FlatColor.black
		case .red:
			customColor = FlatColor.red
		case .green:
			customColor = FlatColor.green
		case .blue:
			customColor = FlatColor.blue
		case .yellow:
			customColor = FlatColor.yellow
		}

		return customColor
	}
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct ColorProvider: PreviewProvider {
	static func makeLabel(customColor: Theme.Color) -> UIView {
		let label = UILabel()
		label.backgroundColor = Theme.color(usage: customColor)
		label.text = "Welcome: " + customColor.rawValue
		label.layer.borderWidth = 1
		label.layer.borderColor = UIColor.black.cgColor

		if case customColor = Theme.Color.main {
			label.textColor = .white
		}
		if case customColor = Theme.Color.black {
			label.textColor = .white
		}
		if case customColor = Theme.Color.allDayBlack {
			label.textColor = .white
		}

		return label
	}

	static var previews: some View {
		let main = makeLabel(customColor: .main)
		let main2 = makeLabel(customColor: .main)
		main2.overrideUserInterfaceStyle = .dark
		let accent = makeLabel(customColor: .accent)
		let background = makeLabel(customColor: .background)
		let attention = makeLabel(customColor: .attention)
		let white = makeLabel(customColor: .white)
		let black = makeLabel(customColor: .black)
		let lightGray = makeLabel(customColor: .lightGray)
		let lightGray2 = makeLabel(customColor: .lightGray)
		lightGray2.overrideUserInterfaceStyle = .dark
		let gray = makeLabel(customColor: .gray)
		let red = makeLabel(customColor: .red)
		let green = makeLabel(customColor: .green)
		let blue = makeLabel(customColor: .blue)
		let allDayWhite = makeLabel(customColor: .allDayWhite)
		let allDayBlack = makeLabel(customColor: .allDayBlack)
		let yellow = makeLabel(customColor: .yellow)

		return Group {
			VStack(spacing: 0) {
				main.preview().frame(height: 30)
				main2.preview().frame(height: 60)
				white.preview().frame(height: 30)
				black.preview().frame(height: 60)
				lightGray.preview().frame(height: 30)
				lightGray2.preview().frame(height: 60)

				allDayWhite.preview().frame(height: 30)
				allDayBlack.preview().frame(height: 30)
			}
			VStack(spacing: 0) {
				accent.preview().frame(height: 60)
				background.preview().frame(height: 60)
				attention.preview().frame(height: 60)

				red.preview().frame(height: 30)
				green.preview().frame(height: 30)
				blue.preview().frame(height: 30)
				gray.preview().frame(height: 30)
				yellow.preview().frame(height: 30)
			}
		}
	}
}
#endif
