import UIKit
import Kingfisher

final class MyNftsItemCell: UITableViewCell {
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
	fileprivate var author: String = "" {
		didSet { authorLabel.text = author }
	}
	fileprivate var price: String = "" {
		didSet { priceLabel.text = price }
	}
	fileprivate var onTapFavorite: (() -> Void)? {
		didSet { likeButton.event = onTapFavorite }
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
	fileprivate lazy var authorPrefixLabel: UILabel = LabelFactory.makeLabel(
		font: Theme.font(style: .subhead)
	)
	private lazy var authorLabel: UILabel = LabelFactory.makeLabel(
		font: Theme.font(style: .footnote)
	)
	fileprivate lazy var priceTitleLabel: UILabel = LabelFactory.makeLabel(
		font: Theme.font(style: .footnote)
	)
	private lazy var priceLabel: UILabel = LabelFactory.makeLabel(
		font: Theme.font(style: .headline)
	)

	// MARK: - Inits

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

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
		authorLabel.text = nil
		priceLabel.text = nil
	}
}

// MARK: - Data model for cell

struct MyNftsItemCellModel {
	let avatarImageURL: URL?
	let isFavorite: Bool
	let title: String
	let rating: Int
	let author: String
	let price: String
	let onTapFavorite: (() -> Void)?

	var someTextBy: String = L10n.Profile.someTextBy
	var someTextPrice: String = L10n.Profile.someTextPrice
}

// MARK: - ICellViewModel

extension MyNftsItemCellModel: ICellViewModel {
	func setup(cell: MyNftsItemCell) {
		cell.imageUrl = avatarImageURL
		cell.isFavorite = isFavorite
		cell.onTapFavorite = onTapFavorite
		cell.titleText = title
		cell.rating = rating
		cell.author = author
		cell.price = price

		cell.authorPrefixLabel.text = someTextBy
		cell.priceTitleLabel.text = someTextPrice
	}
}

// MARK: - UI
private extension MyNftsItemCell {
	func applyStyle() {
		contentView.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
		let avatarContainer = makeAvatarContainerView()
		let middleVStack = makeMiddleVStack()
		let priceVStack = makePriceVStack()

		let textHStack = UIStackView(
			arrangedSubviews: [
				middleVStack,
				UIView(),
				priceVStack
			]
		)
		textHStack.alignment = .center

		let mainHStack = UIStackView(
			arrangedSubviews: [
				avatarContainer,
				textHStack
			]
		)
		mainHStack.alignment = .center
		mainHStack.spacing = Theme.spacing(usage: .constant20)

		contentView.addSubview(mainHStack)
		mainHStack.makeEqualToSuperview(
			insets: .init(all: Theme.spacing(usage: .standard2))
		)
	}

	func makeAvatarContainerView() -> UIView {
		let view = UIView(
			subviews: avatarImageView, likeButton
		)
		avatarImageView.makeEqualToSuperview()
		likeButton.makeConstraints { make in
			[
				make.topAnchor.constraint(equalTo: view.topAnchor),
				make.trailingAnchor.constraint(equalTo: view.trailingAnchor)
			]
		}
		avatarImageView.makeConstraints { $0.size(Appearance.imageSize) }

		return view
	}

	func makeMiddleVStack() -> UIStackView {
		let authorContainerHStack = UIStackView(arrangedSubviews: [authorPrefixLabel, authorLabel])
		authorContainerHStack.spacing = Theme.spacing(usage: .standardHalf)
		authorContainerHStack.alignment = .center
		authorLabel.makeConstraints {
			[$0.heightAnchor.constraint(equalToConstant: Appearance.authorLabelHeight)]
		}

		let middleVStack = UIStackView(
			arrangedSubviews: [
				titleLabel,
				ratingView,
				authorContainerHStack
			]
		)
		middleVStack.axis = .vertical
		middleVStack.spacing = Theme.spacing(usage: .standardHalf)
		middleVStack.setCustomSpacing(Appearance.stackCustomSpacing, after: ratingView)
		middleVStack.alignment = .leading
		titleLabel.makeConstraints {
			[$0.heightAnchor.constraint(equalToConstant: Appearance.titleLabelHeight)]
		}
		ratingView.makeConstraints {
			[$0.heightAnchor.constraint(equalToConstant: Appearance.ratingViewHeight)]
		}

		return middleVStack
	}

	func makePriceVStack() -> UIStackView {
		let priceVStack = UIStackView(
			arrangedSubviews: [
				priceTitleLabel,
				priceLabel
			]
		)
		priceVStack.axis = .vertical
		priceVStack.spacing = Appearance.stackCustomPriceSpacing
		priceVStack.alignment = .leading
		priceTitleLabel.makeConstraints {
			[$0.heightAnchor.constraint(equalToConstant: Appearance.priceTitleLabelHeight)]
		}
		priceLabel.makeConstraints {
			[$0.heightAnchor.constraint(equalToConstant: Appearance.priceLabelHeight)]
		}

		return priceVStack
	}
}

private extension MyNftsItemCell {
	enum Appearance {
		static let imagePlaceholder = Theme.image(kind: .imagePlaceholder)
		static let imageSize: CGSize = .init(width: 108, height: 108)
		static let titleLabelHeight = 22.0
		static let ratingViewHeight = 12.0
		static let priceTitleLabelHeight = 18.0
		static let priceLabelHeight = 22.0
		static let authorLabelHeight = 18.0
		static let stackCustomSpacing = 5.0
		static let stackCustomPriceSpacing = 2.0
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
struct MyNftsItemCellProvider: PreviewProvider {
	static var previews: some View {
		let model = MyNftsItemCellModel(
			avatarImageURL: nil,
			isFavorite: true,
			title: "Lilo",
			rating: 3,
			author: "John Doe",
			price: Theme.getPriceStringFromDouble(1.78),
			onTapFavorite: nil
		)
		let cell = MyNftsItemCell()
		model.setup(cell: cell)

		return Group {
			VStack(spacing: 0) {
				cell.preview().frame(width: 375, height: 140)
			}.preferredColorScheme(.dark)
			VStack(spacing: 0) {
				cell.preview().frame(width: 375, height: 140)
			}.preferredColorScheme(.light)
		}
	}
}
#endif
