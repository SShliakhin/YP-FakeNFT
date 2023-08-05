import UIKit

extension Theme {
	// MARK: - Images
	enum ImageAsset: String {
		case sortIcon
		case addToCartIcon
		case deleteFromCartIcon
	}

	static func image(kind: ImageAsset) -> UIImage {
		return UIImage(named: kind.rawValue) ?? .actions // swiftlint:disable:this image_name_initialization
	}

	enum ImageSF3: String {
		case goBack
		case ratingStar
		case ratingStarFill
		case favorite
		case favoriteFill
		case editProfile
		case close
		case showDetail
	}

	static func image(kind: ImageSF3) -> UIImage {
		let customImage: UIImage

		switch kind {
		case .goBack:
			customImage = UIImage(systemName: "chevron.backward") ?? .actions
		case .ratingStar:
			customImage = UIImage(systemName: "star.fill")?.withTintColor(Theme.color(usage: .allDayWhite)) ?? .actions
		case .ratingStarFill:
			customImage = UIImage(systemName: "star.fill")?.withTintColor(Theme.color(usage: .yellow)) ?? .actions
		case .favorite:
			customImage = UIImage(systemName: "heart.fill")?.withTintColor(Theme.color(usage: .allDayWhite)) ?? .actions
		case .favoriteFill:
			customImage = UIImage(systemName: "heart.fill")?.withTintColor(Theme.color(usage: .red)) ?? .actions
		case .editProfile:
			customImage = UIImage(systemName: "square.and.pencil") ?? .actions
		case .close:
			customImage = UIImage(systemName: "xmark") ?? .actions
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

		if case kind = Theme.ImageSF3.ratingStar {
			label.backgroundColor = Theme.color(usage: .background)
		}
		if case kind = Theme.ImageSF3.favorite {
			label.backgroundColor = Theme.color(usage: .background)
		}

		return label
	}

	static var previews: some View {
		let sortIcon = makeLabel(kind: .sortIcon)
		let addToCartIcon = makeLabel(kind: .addToCartIcon)
		let deleteFromCartIcon = makeLabel(kind: .deleteFromCartIcon)
		let goBack = makeLabel(kind: .goBack)
		let showDetail = makeLabel(kind: .showDetail)
		let ratingStar = makeLabel(kind: .ratingStar)
		let ratingStarFill = makeLabel(kind: .ratingStarFill)
		let favorite = makeLabel(kind: .favorite)
		let favoriteFill = makeLabel(kind: .favoriteFill)
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
				ratingStar.preview().frame(height: 30)
				ratingStarFill.preview().frame(height: 30)
				favorite.preview().frame(height: 30)
				favoriteFill.preview().frame(height: 30)
				editProfile.preview().frame(height: 30)
				close.preview().frame(height: 30)
			}
		}
	}
}
#endif
