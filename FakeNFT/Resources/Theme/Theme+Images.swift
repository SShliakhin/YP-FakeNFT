import UIKit

extension Theme {
	// MARK: - Images
	enum ImageAsset: String {
		case sortIcon
		case addToCartIcon
		case deleteFromCartIcon
		case star
		case heart

		case bagIcon
		case statisticsIcon
		case catalogIcon
		case profileIcon

		case imagePlaceholder
		case logo

		case onboardingPage1
		case onboardingPage2
		case onboardingPage3
	}

	static func image(kind: ImageAsset) -> UIImage {
		return UIImage(named: kind.rawValue) ?? .actions
	}

	enum ImageSF3: String {
		case goBack
		case editProfile
		case close
		case showDetail
	}

	static func getSymbolConfiguration(
		textStyle: UIFont.TextStyle,
		weight: UIImage.SymbolWeight
	) -> UIImage.SymbolConfiguration {
		let textStyle = UIImage.SymbolConfiguration(textStyle: textStyle)
		let weight = UIImage.SymbolConfiguration(weight: weight)
		return textStyle.applying(weight)
	}

	static func image(kind: ImageSF3) -> UIImage {
		let customImage: UIImage

		switch kind {
		case .goBack:
			let combined = getSymbolConfiguration(textStyle: .headline, weight: .semibold)
			customImage = UIImage(systemName: "chevron.backward")?
				.withConfiguration(combined) ?? .actions
		case .editProfile:
			let combined = getSymbolConfiguration(textStyle: .headline, weight: .bold)
			customImage = UIImage(systemName: "square.and.pencil")?
				.withConfiguration(combined) ?? .actions
		case .close:
			let combined = getSymbolConfiguration(textStyle: .headline, weight: .bold)
			customImage = UIImage(systemName: "xmark")?
				.withConfiguration(combined) ?? .actions
		case .showDetail:
			customImage = UIImage(systemName: "chevron.forward") ?? .actions
		}

		return customImage
	}
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct ImageProvider: PreviewProvider {
	static func makeLabel(kind: Theme.ImageAsset) -> UIView {
		let attachment = NSTextAttachment(image: Theme.image(kind: kind))
		let imageString = NSMutableAttributedString(attachment: attachment)
		let textString = NSAttributedString(string: kind.rawValue)
		imageString.append(textString)

		let label = UILabel()
		label.attributedText = imageString
		label.sizeToFit()

		return label
	}

	static func makeLabel(kind: Theme.ImageSF3) -> UIView {
		let attachment = NSTextAttachment(image: Theme.image(kind: kind))
		let imageString = NSMutableAttributedString(attachment: attachment)
		let textString = NSAttributedString(string: kind.rawValue)
		imageString.append(textString)

		let label = UILabel()
		label.attributedText = imageString
		label.sizeToFit()

		return label
	}

	static var previews: some View {
		let sortIcon = makeLabel(kind: .sortIcon)
		let addToCartIcon = makeLabel(kind: .addToCartIcon)
		let deleteFromCartIcon = makeLabel(kind: .deleteFromCartIcon)
		let goBack = makeLabel(kind: .goBack)
		let showDetail = makeLabel(kind: .showDetail)
		let editProfile = makeLabel(kind: .editProfile)
		let close = makeLabel(kind: .close)

		return Group {
			VStack(spacing: 0) {
				sortIcon.preview().frame(height: 60)
				addToCartIcon.preview().frame(height: 60)
				deleteFromCartIcon.preview().frame(height: 60)
			}
			VStack(spacing: 0) {
				goBack.preview().frame(height: 30)
				showDetail.preview().frame(height: 30)
				editProfile.preview().frame(height: 30)
				close.preview().frame(height: 30)
			}
		}
	}
}
#endif
