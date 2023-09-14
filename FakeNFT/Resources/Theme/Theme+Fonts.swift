import UIKit

enum Theme {
	// MARK: - Fonts
	enum FontStyle {
		case preferred(style: UIFont.TextStyle)
		case largeTitle // bold34
		case title1 // bold32
		case title2 // bold22
		case headline // bold17
		case body // regular17
		case subhead // regular15
		case footnote // regular13
		case caption // medium10
	}

	static func font(style: FontStyle) -> UIFont {
		let customFont: UIFont

		switch style {
		case let .preferred(style: style):
			customFont = UIFont.preferredFont(forTextStyle: style)
		case .largeTitle:
			customFont = .systemFont(ofSize: 34, weight: .bold)
		case .title1:
			customFont = .systemFont(ofSize: 32, weight: .bold)
		case .title2:
			customFont = .systemFont(ofSize: 22, weight: .bold)
		case .headline:
			customFont = .systemFont(ofSize: 17, weight: .bold)
		case .body:
			customFont = .systemFont(ofSize: 17, weight: .regular)
		case .subhead:
			customFont = .systemFont(ofSize: 15, weight: .regular)
		case .footnote:
			customFont = .systemFont(ofSize: 13, weight: .regular)
		case .caption:
			customFont = .systemFont(ofSize: 10, weight: .medium)
		}
		return customFont
	}
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct ViewProvider: PreviewProvider {
	static func makeLabel(customFont: Theme.FontStyle, text: String) -> UIView {
		let label = UILabel()
		label.font = Theme.font(style: customFont)
		label.text = text

		return label
	}

	static var previews: some View {
		let largeTitle = makeLabel(customFont: .largeTitle, text: "Welcome bold34")
		let title1 = makeLabel(customFont: .title1, text: "Welcome bold32")
		let title2 = makeLabel(customFont: .title2, text: "Welcome bold22")
		let headline = makeLabel(customFont: .headline, text: "Welcome bold17")
		let body = makeLabel(customFont: .body, text: "Welcome regular17")
		let subhead = makeLabel(customFont: .subhead, text: "Welcome regular15")
		let footnote = makeLabel(customFont: .footnote, text: "Welcome regular13")
		let caption = makeLabel(customFont: .caption, text: "Welcome medium10")

		return Group {
			VStack(spacing: 0) {
				largeTitle.preview().frame(height: 40)
				title1.preview().frame(height: 40)
				title2.preview().frame(height: 40)
				headline.preview().frame(height: 40)
				body.preview().frame(height: 40)
				subhead.preview().frame(height: 40)
				footnote.preview().frame(height: 40)
				caption.preview().frame(height: 40)
			}
		}
	}
}
#endif
