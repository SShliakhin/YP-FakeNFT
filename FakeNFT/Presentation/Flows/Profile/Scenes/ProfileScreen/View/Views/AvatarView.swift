import UIKit
import Kingfisher

final class AvatarView: UIView {
	var avatarUrl: URL? {
		profileAvatarUrl
	}
	private var profileAvatarUrl: URL? {
		didSet {
			guard
				oldValue != profileAvatarUrl,
				let url = profileAvatarUrl
			else { return }
			updateAvatarImageByUrl(url)
		}
	}

	// MARK: - UI Elements
	private lazy var avatarImageView: UIImageView = makeAvatarImageView()
	private lazy var avatarButton: UIButton = makeAvatarButton()
	private lazy var uploadImageButton: UIButton = ButtonFactory.makeTextButton(
		textFont: Theme.font(style: .body)
	)
	private lazy var uploadImageButtonContainer = UIView()

	// MARK: - Inits

	override init(frame: CGRect) {
		super.init(frame: frame)

		applyStyle()
		setConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Data model for view

struct AvatarViewModel {
	let url: URL?
	let isUploadButtonHidden: Bool
	let onTapUploadImage: (() -> Void)?

	var buttonChangePhotoTitle: String = L10n.Profile.buttonTitleChangePhoto
	var buttonUploadPhotoTitle: String = L10n.Profile.buttonTitleUploadImage
}

// MARK: - Update
extension AvatarView {
	@discardableResult
	func update(with model: AvatarViewModel) -> Self {
		profileAvatarUrl = model.url
		uploadImageButtonContainer.isHidden = model.isUploadButtonHidden
		uploadImageButton.event = model.onTapUploadImage

		avatarButton.setTitle(model.buttonChangePhotoTitle, for: .normal)
		uploadImageButton.setTitle(model.buttonUploadPhotoTitle, for: .normal)

		return self
	}
}

// MARK: - UI
private extension AvatarView {
	func applyStyle() {
		backgroundColor = .clear
	}
	func setConstraints() {
		let imageContainer = UIView(
			subviews: avatarImageView, avatarButton
		)
		avatarImageView.makeConstraints {
			$0.size(Appearance.avatarSize)
		}
		avatarImageView.makeEqualToSuperview()
		avatarButton.makeEqualToSuperview()

		uploadImageButtonContainer.addSubview(uploadImageButton)
		uploadImageButton.makeConstraints {
			[$0.heightAnchor.constraint(equalToConstant: Appearance.buttonLimitHeight)]
		}
		uploadImageButton.makeEqualToSuperview(insets: Appearance.buttonInsets)

		let vStack = UIStackView(
			arrangedSubviews: [imageContainer, uploadImageButtonContainer]
		)
		vStack.axis = .vertical
		vStack.alignment = .center

		addSubview(vStack)
		vStack.makeEqualToSuperview()
	}
}

// MARK: - UI make
private extension AvatarView {
	func makeAvatarImageView() -> UIImageView {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.layer.cornerRadius = Appearance.avatarCornerRadius
		imageView.layer.masksToBounds = true

		imageView.kf.indicatorType = .activity

		return imageView
	}
	func makeAvatarButton() -> UIButton {
		let button = UIButton(type: .custom)
		button.backgroundColor = Theme.color(usage: .allDayBlack).withAlphaComponent(0.6)
		button.layer.cornerRadius = Appearance.avatarCornerRadius
		button.titleLabel?.numberOfLines = 2
		button.titleLabel?.textAlignment = .center
		button.titleLabel?.font = Theme.font(style: .caption)
		button.setTitleColor(Theme.color(usage: .allDayWhite), for: .normal)
		button.event = { [weak self] in
			guard let self = self else { return }
			self.uploadImageButtonContainer.isHidden = !self.uploadImageButtonContainer.isHidden
		}

		return button
	}
}

private extension AvatarView {
	func updateAvatarImageByUrl(_ imageURL: URL) {
		avatarImageView.kf.setImage(
			with: imageURL,
			placeholder: Appearance.imagePlaceholder,
			options: [.transition(.fade(0.2))]
		) { [weak self] result in
			guard let self = self else { return }
			if case .failure = result {
				self.avatarImageView.image = Appearance.imagePlaceholder
			}
		}
	}
}

private extension AvatarView {
	enum Appearance {
		static let imagePlaceholder = Theme.image(kind: .imagePlaceholder)
		static let avatarSize: CGSize = .init(width: 70, height: 70)
		static let avatarCornerRadius = 35.0
		static let buttonInsets: UIEdgeInsets = .init(
			horizontal: Theme.spacing(usage: .standard2),
			vertical: 11.0
		)
		static let buttonLimitHeight = 22.0

		static let mockUrls: [URL?] = [
			URL(string: "https://avatars.mds.yandex.net/get-kinopoisk-image/1629390/382f1545-aa14-4a7f-8f89-a1afb4656923/3840x"),
			URL(string: "https://avatars.mds.yandex.net/get-kinopoisk-image/1704946/6a1e205b-1fa4-480e-a57d-a14415362b96/3840x")
		]
	}
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct AvatarViewPreviews: PreviewProvider {
	static var previews: some View {
		let model = AvatarViewModel(
			url: AvatarView.Appearance.mockUrls.last!, // swiftlint:disable:this force_unwrapping
			isUploadButtonHidden: false,
			onTapUploadImage: nil
		)
		let avatarView = AvatarView().update(with: model)
		let model2 = AvatarViewModel(
			url: AvatarView.Appearance.mockUrls.first!, // swiftlint:disable:this force_unwrapping
			isUploadButtonHidden: false,
			onTapUploadImage: nil
		)
		let avatarView2 = AvatarView().update(with: model2)

		return Group {
			VStack(spacing: 10) {
				avatarView2.preview().frame(width: 375, height: 114)
			}
			.preferredColorScheme(.light)
			VStack(spacing: 10) {
				avatarView.preview().frame(width: 375, height: 114)
			}
			.preferredColorScheme(.dark)
		}
	}
}
#endif
