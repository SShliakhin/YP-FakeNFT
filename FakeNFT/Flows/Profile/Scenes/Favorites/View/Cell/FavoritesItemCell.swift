import UIKit
import Kingfisher

final class FavoritesItemCell: UICollectionViewCell {
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
	fileprivate var titleText: String = "" {
		didSet { titleLabel.text = titleText }
	}
	fileprivate var rating: Int = .zero {
		didSet { ratingView.update(with: rating) }
	}
	fileprivate var price: String = "" {
		didSet { priceLabel.text = price }
	}
	fileprivate var onTapFavorite: (() -> Void)? {
		didSet { likeButton.event = onTapFavorite }
	}

	// MARK: - UI Elements

	private lazy var avatarImageView: UIImageView = makeAvatarImageView()
	private lazy var likeButton: UIButton = makeLikeButton()
	private lazy var titleLabel: UILabel = makeTitleLabel()
	private lazy var ratingView = RatingView()
	private lazy var priceLabel: UILabel = makePriceLabel()

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
	}
}

// MARK: - Data model for cell

struct FavoritesItemCellModel {
	let avatarImageURL: URL?
	let isFavorite: Bool
	let title: String
	let rating: Int
	let price: String
	let onTapFavorite: (() -> Void)?
}

// MARK: - ICellViewModel

extension FavoritesItemCellModel: ICellViewModel {
	func setup(cell: FavoritesItemCell) {
		cell.imageUrl = avatarImageURL
		cell.isFavorite = isFavorite
		cell.onTapFavorite = onTapFavorite
		cell.titleText = title
		cell.rating = rating
		cell.price = price
	}
}

// MARK: - UI
private extension FavoritesItemCell {
	func applyStyle() {
		contentView.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
		let avatarContainer = makeAvatarContainerView()
		let vStack = makeVStack()

		let mainHStack = UIStackView(
			arrangedSubviews: [
				avatarContainer,
				vStack
			]
		)
		mainHStack.alignment = .center
		mainHStack.spacing = Appearance.stackCustomSpacing

		contentView.addSubview(mainHStack)
		mainHStack.makeEqualToSuperview()
	}

	func makeAvatarContainerView() -> UIView {
		let view = UIView()
		[
			avatarImageView,
			likeButton
		].forEach { view.addSubview($0) }
		avatarImageView.makeEqualToSuperview()
		likeButton.makeConstraints { make in
			[
				make.topAnchor.constraint(equalTo: view.topAnchor, constant: Appearance.likeButtonInset),
				make.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Appearance.likeButtonInset)
			]
		}
		avatarImageView.makeConstraints { $0.size(Appearance.imageSize) }

		return view
	}

	func makeVStack() -> UIStackView {
		let stack = UIStackView(
			arrangedSubviews: [
				titleLabel,
				ratingView,
				priceLabel
			]
		)
		stack.axis = .vertical
		stack.spacing = Theme.spacing(usage: .standardHalf)
		stack.setCustomSpacing(Theme.spacing(usage: .standard), after: ratingView)
		stack.alignment = .leading
		titleLabel.makeConstraints {
			[$0.heightAnchor.constraint(equalToConstant: Appearance.titleLabelHeight)]
		}
		ratingView.makeConstraints {
			[$0.heightAnchor.constraint(equalToConstant: Appearance.ratingViewHeight)]
		}
		priceLabel.makeConstraints {
			[$0.heightAnchor.constraint(equalToConstant: Appearance.priceLabelHeight)]
		}

		return stack
	}
}

// MARK: - UI make
private extension FavoritesItemCell {
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
		label.font = Theme.font(style: .subhead)

		return label
	}
}

private extension FavoritesItemCell {
	enum Appearance {
		static let imagePlaceholder = Theme.image(kind: .imagePlaceholder)
		static let imageSize: CGSize = .init(width: 80, height: 80)
		static let titleLabelHeight = 22.0
		static let ratingViewHeight = 12.0
		static let priceLabelHeight = 20.0
		static let stackCustomSpacing = 12.0
		static let likeButtonInset = -6.0 // выступает за родителя
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

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct FavoritesItemCellProvider: PreviewProvider {
	static var previews: some View {
		let model = FavoritesItemCellModel(
			avatarImageURL: nil,
			isFavorite: true,
			title: "Archie",
			rating: 1,
			price: "1,78",
			onTapFavorite: nil
		)
		let cell = FavoritesItemCell()
		model.setup(cell: cell)

		let model2 = FavoritesItemCellModel(
			avatarImageURL: nil,
			isFavorite: true,
			title: "Pixi",
			rating: 3,
			price: "1,78",
			onTapFavorite: nil
		)
		let cell2 = FavoritesItemCell()
		model2.setup(cell: cell2)

		return Group {
			HStack(spacing: 7) {
				cell.preview().frame(width: 168, height: 80)
				cell2.preview().frame(width: 168, height: 80)
			}.preferredColorScheme(.dark)
			HStack(spacing: 7) {
				cell.preview().frame(width: 168, height: 80)
				cell2.preview().frame(width: 168, height: 80)
			}.preferredColorScheme(.light)
		}
	}
}
#endif
