import UIKit
import Kingfisher

enum ImageViewFactory {
	static func makeImageView(
		image: UIImage,
		cornerRadius: CGFloat = .zero,
		isMasksToBounds: Bool = false,
		contentMode: UIView.ContentMode = .scaleAspectFill
	) -> UIImageView {
		let imageView = UIImageView(image: image)
		imageView.contentMode = contentMode
		imageView.layer.cornerRadius = cornerRadius
		imageView.layer.masksToBounds = isMasksToBounds

		return imageView
	}

	static func makeImageViewKF(
		cornerRadius: CGFloat = Theme.dimension(kind: .largeRadius),
		isMasksToBounds: Bool = true,
		contentMode: UIView.ContentMode = .scaleAspectFill,
		kfIndicatorType: IndicatorType = .activity
	) -> UIImageView {
		let imageView = UIImageView()
		imageView.contentMode = contentMode
		imageView.layer.cornerRadius = cornerRadius
		imageView.layer.masksToBounds = isMasksToBounds

		imageView.kf.indicatorType = kfIndicatorType

		return imageView
	}
}
