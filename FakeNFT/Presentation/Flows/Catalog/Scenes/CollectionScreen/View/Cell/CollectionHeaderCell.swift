import UIKit
import Kingfisher

final class CollectionHeaderCell: UICollectionViewCell {
	fileprivate var imageUrl: URL? {
		didSet { updateCoverImageByUrl(imageUrl) }
	}

	fileprivate var titleText: String = "" {
		didSet { titleLabel.text = titleText }
	}

	fileprivate var authorText: NSAttributedString? {
		didSet { authorLabel.attributedText = authorText }
	}

	fileprivate var descriptionText: String = "" {
		didSet { descriptionLabel.text = descriptionText }
	}

	fileprivate var onTapAuthor: (() -> Void)?

	// MARK: - UI Elements

	private lazy var coverImageView: UIImageView = makeCoverImageView()
	private lazy var titleLabel: UILabel = LabelFactory.makeLabel(
		font: Theme.font(style: .title2)
	)
	private lazy var authorLabel: UILabel = LabelFactory.makeTapLabel(
		tap: UITapGestureRecognizer(
			target: self,
			action: #selector(handleOnTapAuthor)
		)
	)
	private lazy var descriptionLabel: UILabel = LabelFactory.makeLabel(
		font: Theme.font(style: .footnote),
		numberOfLines: .zero
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

		coverImageView.kf.cancelDownloadTask()

		coverImageView.image = nil
		titleLabel.text = nil
		authorLabel.attributedText = nil
		descriptionLabel.text = nil
	}
}

// MARK: - Actions
private extension CollectionHeaderCell {
	@objc func handleOnTapAuthor() {
		onTapAuthor?()
	}
}

// MARK: - Data model for cell

struct CollectionHeaderCellModel {
	let imageURL: URL?
	let title: String
	let author: String
	let description: String
	let onTapAuthor: (() -> Void)?

	var authorText: String {
		"\(L10n.Author.textPrefix) \(author)"
	}
}

// MARK: - ICellViewModel

extension CollectionHeaderCellModel: ICellViewModel {
	func setup(cell: CollectionHeaderCell) {
		let data = LinkInsideTextInputData(
			text: authorText,
			mainFont: Theme.font(style: .footnote),
			mainColor: Theme.color(usage: .main),
			linkFont: Theme.font(style: .subhead),
			linkColor: Theme.color(usage: .blue),
			linkText: author
		)

		cell.imageUrl = imageURL

		cell.titleText = title
		cell.authorText = makeLinkInsideText(data: data)
		cell.descriptionText = description
		cell.onTapAuthor = onTapAuthor
	}
}

// MARK: - UI
private extension CollectionHeaderCell {
	func applyStyle() {
		contentView.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
		let vStack = UIStackView()
		vStack.axis = .vertical
		vStack.alignment = .leading
		vStack.spacing = Appearance.textStackSpacing
		[
			titleLabel,
			authorLabel,
			descriptionLabel
		].forEach { vStack.addArrangedSubview($0) }
		vStack.setCustomSpacing(Appearance.stackCustomSpacing, after: authorLabel)

		let view = UIView()
		view.addSubview(vStack)
		vStack.makeEqualToSuperview(insets: Appearance.textContentInsets)

		let mainVStack = UIStackView(arrangedSubviews: [coverImageView, view])
		mainVStack.axis = .vertical
		mainVStack.spacing = Theme.spacing(usage: .standard2)

		contentView.addSubview(mainVStack)
		mainVStack.makeEqualToSuperview()
	}
}

// MARK: - UI make
private extension CollectionHeaderCell {
	func makeCoverImageView() -> UIImageView {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.layer.cornerRadius = Theme.dimension(kind: .largeRadius)
		imageView.layer.masksToBounds = true

		imageView.kf.indicatorType = .activity

		return imageView
	}
}

private extension CollectionHeaderCellModel {
	struct LinkInsideTextInputData {
		let text: String
		let mainFont: UIFont
		let mainColor: UIColor
		let linkFont: UIFont
		let linkColor: UIColor
		let linkText: String
	}

	func makeLinkInsideText(data: LinkInsideTextInputData) -> NSMutableAttributedString {
		let mainTextAttributes = [
			NSAttributedString.Key.font: data.mainFont,
			NSAttributedString.Key.foregroundColor: data.mainColor
		]
		let attributedText = NSMutableAttributedString(string: data.text, attributes: mainTextAttributes)
		let linkRange = (data.text as NSString).range(of: data.linkText)
		attributedText.addAttribute(.font, value: data.linkFont, range: linkRange)
		attributedText.addAttribute(.foregroundColor, value: data.linkColor, range: linkRange)

		return attributedText
	}
}

private extension CollectionHeaderCell {
	enum Appearance {
		static let imagePlaceholder = Theme.image(kind: .imagePlaceholder)
		static let imageWidth = UIScreen.main.bounds.width
		static let textStackSpacing = 13.0
		static let stackCustomSpacing = 5.0
		static let textContentInsets: UIEdgeInsets = .init(
			horizontal: Theme.spacing(usage: .standard2),
			vertical: .zero
		)
	}

	func updateCoverImageByUrl(_ url: URL?) {
		coverImageView.kf.setImage(
			with: url,
			placeholder: Appearance.imagePlaceholder,
			options: [.transition(.fade(0.2))]
		) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let value):
				self.coverImageView.image = value.image
					.resize(withWidth: Appearance.imageWidth)
			case .failure:
				self.coverImageView.image = Appearance.imagePlaceholder
				self.contentMode = .center
			}
		}
	}
}
