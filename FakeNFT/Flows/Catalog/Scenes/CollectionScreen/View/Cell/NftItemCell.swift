import UIKit
import Kingfisher
import ProgressHUD

final class NftItemCell: UICollectionViewCell {
	fileprivate static let imagePlaceholder = Theme.image(kind: .imagePlaceholder)

	// MARK: - UI Elements

	fileprivate lazy var avatarImageView: UIImageView = makeAvatarImageView()
	fileprivate lazy var likeButton: UIButton = makeLikeButton()
	fileprivate lazy var ratingView = RatingView()
	fileprivate lazy var titleLabel: UILabel = makeTitleLabel()
	fileprivate lazy var priceLabel: UILabel = makePriceLabel()
	fileprivate lazy var cartButton: UIButton = makeCartButton()

	// MARK: - Inits

	override init(frame: CGRect) {
		super.init(frame: frame)

		setConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Life cycle

	override func prepareForReuse() {
		super.prepareForReuse()

		avatarImageView.image = nil
		likeButton.tintColor = Theme.color(usage: .allDayWhite)
		ratingView.update(with: .zero)
		titleLabel.text = nil
		priceLabel.text = nil
		cartButton.setBackgroundImage(Theme.image(kind: .addToCartIcon), for: .normal)

		avatarImageView.kf.cancelDownloadTask()
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
		cell.avatarImageView.kf.setImage(
			with: avatarImageURL,
			placeholder: NftItemCell.imagePlaceholder,
			options: [.transition(.fade(0.2))]
		) { [weak cell] result in
			guard let cell = cell else { return }
			if case .failure = result {
				cell.avatarImageView.image = NftItemCell.imagePlaceholder
			}
		}

		cell.likeButton.tintColor = isFavorite
		? Theme.color(usage: .red)
		: Theme.color(usage: .allDayWhite)
		cell.likeButton.event = {
			ProgressHUD.show()
			onTapFavorite?()
		}
		cell.ratingView.update(with: rating)
		cell.titleLabel.text = title
		cell.priceLabel.text = "\(price) ETN"
		cell.cartButton.setBackgroundImage(
			isInCart
			? Theme.image(kind: .deleteFromCartIcon)
			: Theme.image(kind: .addToCartIcon),
			for: .normal
		)
		cell.cartButton.event = {
			ProgressHUD.show()
			onTapInCart?()
		}
	}
}

// MARK: - UI
private extension NftItemCell {
	func setConstraints() {
		let avatarContainer = UIView()
		[
			avatarImageView,
			likeButton
		].forEach { avatarContainer.addSubview($0) }
		avatarImageView.makeEqualToSuperview()
		likeButton.makeConstraints { make in
			[
				make.topAnchor.constraint(equalTo: avatarContainer.topAnchor),
				make.trailingAnchor.constraint(equalTo: avatarContainer.trailingAnchor)
			]
		}

		let leftVStack = UIStackView(arrangedSubviews: [titleLabel, priceLabel])
		leftVStack.axis = .vertical
		leftVStack.spacing = Theme.spacing(usage: .standardHalf)
		leftVStack.alignment = .leading
		titleLabel.makeConstraints { [$0.heightAnchor.constraint(equalToConstant: 22)] }
		priceLabel.makeConstraints { [$0.heightAnchor.constraint(equalToConstant: 12)] }

		let bottomHStack = UIStackView(arrangedSubviews: [leftVStack, cartButton])
		bottomHStack.alignment = .center

		let mainVStack = UIStackView()
		mainVStack.axis = .vertical
		mainVStack.alignment = .leading
		mainVStack.spacing = Theme.spacing(usage: .standard)
		[
			avatarContainer,
			ratingView,
			bottomHStack
		].forEach { mainVStack.addArrangedSubview($0) }
		mainVStack.setCustomSpacing(5, after: ratingView)
		avatarContainer.makeConstraints { [$0.heightAnchor.constraint(equalTo: $0.widthAnchor, multiplier: 1)] }

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

// MARK: - UI make
private extension NftItemCell {
	func makeAvatarImageView() -> UIImageView {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.layer.cornerRadius = Theme.dimension(kind: .largeRadius)
		imageView.layer.masksToBounds = true

		imageView.kf.indicatorType = .activity

		return imageView
	}

	func makeLikeButton() -> UIButton {
		let button = UIButton(type: .custom)
		button.setBackgroundImage(Theme.image(kind: .heart), for: .normal)
		button.tintColor = Theme.color(usage: .allDayWhite)

		return button
	}

	func makeTitleLabel() -> UILabel {
		let label = UILabel()
		label.textColor = Theme.color(usage: .main)
		label.font = Theme.font(style: .headline)

		return label
	}

	func makePriceLabel() -> UILabel {
		let label = UILabel()
		label.textColor = Theme.color(usage: .main)
		label.font = Theme.font(style: .caption)

		return label
	}

	func makeCartButton() -> UIButton {
		let button = UIButton(type: .custom)
		button.setBackgroundImage(Theme.image(kind: .addToCartIcon), for: .normal)
		button.tintColor = Theme.color(usage: .black)

		return button
	}
}
