import UIKit
import Kingfisher

final class ProfileHeaderView: UIView {

	// MARK: - UI Elements
	private lazy var avatarImageView: UIImageView = makeAvatarImageView()
	private lazy var titleLabel: UILabel = LabelFactory.makeLabel(
		font: Theme.font(style: .title2)
	)
	private lazy var descriptionLabel: UILabel = LabelFactory.makeLabel(
		font: Theme.font(style: .footnote)
	)
	private lazy var urlLabel: UILabel = LabelFactory.makeLabel(
		font: Theme.font(style: .subhead),
		textColor: Theme.color(usage: .blue)
	)

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

struct ProfileHeaderViewModel {
	let url: URL?
	let title: String
	let description: String
}

// MARK: - Update
extension ProfileHeaderView {
	@discardableResult
	func update(with profile: Profile) -> Self {
		avatarImageView.kf.setImage(
			with: profile.avatar,
			placeholder: Appearance.imagePlaceholder,
			options: [
				.transition(.fade(0.2)),
				.cacheSerializer(FormatIndicatedCacheSerializer.png)
			]
		) { [weak self] result in
			guard let self = self else { return }
			if case .failure = result {
				self.avatarImageView.image = Appearance.imagePlaceholder
			}
		}
		titleLabel.text = profile.name
		descriptionLabel.text = profile.description
		urlLabel.text = profile.website?.absoluteString

		return self
	}

	@discardableResult
	func update(with model: ProfileHeaderViewModel) -> Self {
		avatarImageView.image = Appearance.imagePlaceholder
		avatarImageView.layer.borderColor = Theme.color(usage: .black).cgColor
		avatarImageView.layer.borderWidth = Appearance.avatarBorderWidth
		titleLabel.text = model.title
		descriptionLabel.text = model.description
		urlLabel.text = model.url?.absoluteString

		return self
	}
}

// MARK: - UI
private extension ProfileHeaderView {
	func applyStyle() {
		backgroundColor = .clear
	}
	func setConstraints() {
		let hStack = UIStackView(arrangedSubviews: [avatarImageView, titleLabel])
		hStack.spacing = Theme.spacing(usage: .standard2)
		avatarImageView.makeConstraints {
			$0.size(Appearance.avatarSize)
		}

		let vStack = UIStackView(arrangedSubviews: [hStack, descriptionLabel, urlLabel])
		vStack.axis = .vertical
		vStack.spacing = Theme.spacing(usage: .constant20)
		vStack.setCustomSpacing(Appearance.afterDescriptionSpace, after: descriptionLabel)

		addSubview(vStack)

		vStack.makeEqualToSuperview(insets: .init(
			top: Theme.spacing(usage: .constant20),
			left: Theme.spacing(usage: .standard2),
			bottom: Appearance.bottomInset,
			right: Theme.spacing(usage: .standard2)
		))
	}
}

// MARK: - UI make
private extension ProfileHeaderView {
	func makeAvatarImageView() -> UIImageView {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.layer.cornerRadius = Appearance.avatarCornerRadius
		imageView.layer.masksToBounds = true

		imageView.kf.indicatorType = .activity

		return imageView
	}
}

private extension ProfileHeaderView {
	enum Appearance {
		static let imagePlaceholder = Theme.image(kind: .imagePlaceholder)
		static let avatarSize: CGSize = .init(width: 70, height: 70)
		static let avatarCornerRadius = 35.0
		static let avatarBorderWidth = 1.0
		static let bottomInset = 44.0
		static let afterDescriptionSpace = 12.0
	}
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct ProfileHeaderViewPreviews: PreviewProvider {
	static var previews: some View {
		let model = ProfileHeaderViewModel(
			url: URL(string: "https://practicum.yandex.ru/ios-developer/"),
			title: "Студент группа 4",
			description: "Прошел 5-й спринт, и этот пройду Прошел 5-й спринт, и этот пройду"
		)
		let header = ProfileHeaderView().update(with: model)

		return Group {
			VStack(spacing: 10) {
				header.preview().frame(width: 375, height: 220)
			}
			.preferredColorScheme(.light)
			VStack(spacing: 10) {
				header.preview().frame(width: 375, height: 220)
			}
			.preferredColorScheme(.dark)
		}
	}
}
#endif
