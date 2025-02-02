import UIKit
import Kingfisher

final class NftItemCell: UICollectionViewCell {
	fileprivate var imageUrl: URL? {
		didSet { updateAvatarImageByUrl(imageUrl) }
	}

	fileprivate var isFavorite = false {
		didSet {
			likeButton.tintColor = isFavorite
			? Theme.color(usage: .red)
			: Theme.color(usage: .allDayWhite)
		}
	}

	fileprivate var onTapFavorite: (() -> Void)? {
		didSet { likeButton.event = onTapFavorite }
	}

	fileprivate var rating: Int = .zero {
		didSet { ratingView.update(with: rating) }
	}

	fileprivate var titleText: String = "" {
		didSet { titleLabel.text = titleText }
	}

	fileprivate var price: Double = .zero {
		didSet { priceLabel.text = "\(price) ETN" }
	}

	fileprivate var isInCart = false {
		didSet {
			cartButton.setBackgroundImage(
				isInCart
				? Theme.image(kind: .deleteFromCartIcon)
				: Theme.image(kind: .addToCartIcon),
				for: .normal
			)
		}
	}

	fileprivate var onTapInCart: (() -> Void)? {
		didSet { cartButton.event = onTapInCart }
	}

	// MARK: - UI Elements

	private lazy var avatarImageView: UIImageView = ImageViewFactory.makeImageViewKF()
	private lazy var likeButton: UIButton = ButtonFactory.makeButton(
		image: Theme.image(kind: .heart),
		tintColor: Theme.color(usage: .allDayWhite)
	)
	private lazy var ratingView = RatingView()
	private lazy var titleLabel: UILabel = LabelFactory.makeLabel(
		font: Theme.font(style: .headline)
	)
	private lazy var priceLabel: UILabel = LabelFactory.makeLabel(
		font: Theme.font(style: .caption)
	)
	private lazy var cartButton: UIButton = ButtonFactory.makeButton(
		image: Theme.image(kind: .addToCartIcon)
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

	// MARK: - Life cycle

	override func prepareForReuse() {
		super.prepareForReuse()

		avatarImageView.kf.cancelDownloadTask()

		avatarImageView.image = nil
		likeButton.tintColor = Theme.color(usage: .allDayWhite)
		ratingView.update(with: .zero)
		titleLabel.text = nil
		priceLabel.text = nil
		cartButton.setBackgroundImage(Theme.image(kind: .addToCartIcon), for: .normal)
	}
}

// MARK: - Data model for cell

struct NftItemCellModel {
	let avatarImageURL: URL?
	let isFavorite: Bool
	let rating: Int
	let title: String
	let price: Double
	let isInCart: Bool
	let onTapFavorite: (() -> Void)?
	let onTapInCart: (() -> Void)?
}

// MARK: - ICellViewModel

extension NftItemCellModel: ICellViewModel {
	func setup(cell: NftItemCell) {
		cell.imageUrl = avatarImageURL
		cell.isFavorite = isFavorite
		cell.onTapFavorite = onTapFavorite
		cell.rating = rating
		cell.titleText = title
		cell.price = price
		cell.isInCart = isInCart
		cell.onTapInCart = onTapInCart
	}
}

// MARK: - UI
private extension NftItemCell {
	func applyStyle() {
		contentView.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
		let avatarContainer = UIView(
			subviews: avatarImageView, likeButton
		)
		avatarImageView.makeEqualToSuperview()
		likeButton.makeConstraints { make in
			[
				make.topAnchor.constraint(equalTo: avatarContainer.topAnchor),
				make.trailingAnchor.constraint(equalTo: avatarContainer.trailingAnchor)
			]
		}

		let leftVStack = UIStackView(
			arrangedSubviews: [titleLabel, priceLabel]
		)
		leftVStack.axis = .vertical
		leftVStack.spacing = Theme.spacing(usage: .standardHalf)
		leftVStack.alignment = .leading
		titleLabel.makeConstraints {
			[$0.heightAnchor.constraint(equalToConstant: Appearance.titleLabelHeight)]
		}
		priceLabel.makeConstraints {
			[$0.heightAnchor.constraint(equalToConstant: Appearance.priceLabelHeight)]
		}

		let bottomHStack = UIStackView(
			arrangedSubviews: [leftVStack, cartButton]
		)
		bottomHStack.alignment = .center

		let mainVStack = UIStackView(
			arrangedSubviews: [avatarContainer, ratingView, bottomHStack]
		)
		mainVStack.axis = .vertical
		mainVStack.alignment = .leading
		mainVStack.spacing = Theme.spacing(usage: .standard)

		mainVStack.setCustomSpacing(Appearance.stackCustomSpacing, after: ratingView)

		avatarContainer.makeConstraints {
			[$0.heightAnchor.constraint(equalTo: $0.widthAnchor, multiplier: 1)]
		}
		bottomHStack.makeConstraints { make in
			[
				make.leadingAnchor.constraint(equalTo: mainVStack.leadingAnchor),
				make.trailingAnchor.constraint(equalTo: mainVStack.trailingAnchor)
			]
		}

		contentView.addSubview(mainVStack)
		mainVStack.makeEqualToSuperview(
			insets: .init(bottom: Theme.spacing(usage: .constant20))
		)
	}
}

private extension NftItemCell {
	enum Appearance {
		static let imagePlaceholder = Theme.image(kind: .imagePlaceholder)
		static let titleLabelHeight = 22.0
		static let priceLabelHeight = 12.0
		static let stackCustomSpacing = 5.0
	}

	func updateAvatarImageByUrl(_ url: URL?) {
		avatarImageView.kf.setImage(
			with: url,
			placeholder: Appearance.imagePlaceholder,
			options: [.transition(.fade(0.2))]
		) { [weak self] result in
			if case .failure = result {
				self?.avatarImageView.image = Appearance.imagePlaceholder
			}
		}
	}
}
