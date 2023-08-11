import UIKit

final class NftItemCell: UICollectionViewCell {
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
		ratingView.update(with: 0)
		titleLabel.text = nil
		priceLabel.text = nil
		cartButton.setBackgroundImage(Theme.image(kind: .addToCartIcon), for: .normal)
	}
}

// MARK: - Data model for cell

struct NftItemCellModel {
	let avatarImageString: String
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
		cell.avatarImageView.image = UIImage(named: avatarImageString)
		cell.likeButton.tintColor = isFavorite
		? Theme.color(usage: .red)
		: Theme.color(usage: .allDayWhite)
		cell.ratingView.update(with: rating)
		cell.titleLabel.text = title
		cell.priceLabel.text = "\(price) ETN"
		cell.cartButton.setBackgroundImage(
			isInCart
			? Theme.image(kind: .deleteFromCartIcon)
			: Theme.image(kind: .addToCartIcon),
			for: .normal
		)
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
		avatarContainer.makeConstraints { $0.size(.init(width: 108, height: 108)) }
		bottomHStack.makeConstraints { make in
			[
				make.leadingAnchor.constraint(equalTo: mainVStack.leadingAnchor),
				make.trailingAnchor.constraint(equalTo: mainVStack.trailingAnchor)
			]
		}

		contentView.addSubview(mainVStack)
		mainVStack.makeEqualToSuperview()
	}
}

// MARK: - UI make
private extension NftItemCell {
	func makeAvatarImageView() -> UIImageView {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.layer.cornerRadius = Theme.dimension(kind: .largeRadius)
		imageView.layer.masksToBounds = true

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

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct NftItemCellPreviews: PreviewProvider {
	static var previews: some View {

		let view1 = NftItemCell()
		let view2 = NftItemCell()
		let view3 = NftItemCell()
		let model1 = NftItemCellModel(
			avatarImageString: "Archie",
			isFavorite: true,
			rating: 5,
			title: "Archie",
			price: 7.74,
			isInCart: true,
			onTapFavorite: nil,
			onTapInCart: nil
		)
		let model2 = NftItemCellModel(
			avatarImageString: "Art",
			isFavorite: false,
			rating: 4,
			title: "Art",
			price: 0.33,
			isInCart: false,
			onTapFavorite: nil,
			onTapInCart: nil
		)
		let model3 = NftItemCellModel(
			avatarImageString: "Biscuit",
			isFavorite: false,
			rating: 4,
			title: "Biscuit",
			price: 1.59,
			isInCart: true,
			onTapFavorite: nil,
			onTapInCart: nil
		)
		model1.setup(cell: view1)
		model2.setup(cell: view2)
		model3.setup(cell: view3)

		return Group {
			HStack {
				view1.preview()
					.frame(width: 108, height: 172)

				view2.preview()
					.frame(width: 108, height: 172)
				view3.preview()
					.frame(width: 108, height: 172)
			}
			.preferredColorScheme(.dark)
			.padding(.vertical, 16)
		}
	}
}
#endif
