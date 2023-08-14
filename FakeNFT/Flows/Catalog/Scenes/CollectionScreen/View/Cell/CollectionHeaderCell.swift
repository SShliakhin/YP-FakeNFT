import UIKit
import Kingfisher

final class CollectionHeaderCell: UICollectionViewCell {
	fileprivate static let imageWidth = UIScreen.main.bounds.width
	fileprivate static let imagePlaceholder = Theme.image(kind: .imagePlaceholder)

	// MARK: - UI Elements

	fileprivate lazy var coverImageView: UIImageView = makeCoverImageView()
	fileprivate lazy var titleLabel: UILabel = makeTitleLabel()
	fileprivate lazy var authorLabel: UILabel = makeAuthorLabel()
	fileprivate lazy var descriptionLabel: UILabel = makeDescriptionLabel()

	fileprivate var onTapAuthor: (() -> Void)?

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
		coverImageView.image = nil
		titleLabel.text = nil
		authorLabel.attributedText = nil
		descriptionLabel.text = nil

		coverImageView.kf.cancelDownloadTask()
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
		"\(Appearance.authorTextPrefix) \(author)"
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

		cell.coverImageView.kf.setImage(
			with: imageURL,
			placeholder: CollectionHeaderCell.imagePlaceholder,
			options: [.transition(.fade(0.2))]
		) { [weak cell] result in
			guard let cell = cell else { return }
			switch result {
			case .success(let value):
				cell.coverImageView.image = value.image
					.resize(withWidth: CollectionHeaderCell.imageWidth)
			case .failure:
				cell.coverImageView.image = CollectionHeaderCell.imagePlaceholder
				cell.contentMode = .center
			}
		}

		cell.titleLabel.text = title
		cell.authorLabel.attributedText = makeLinkInsideText(data: data)
		cell.descriptionLabel.text = description
		cell.onTapAuthor = onTapAuthor
	}
}

// MARK: - UI
private extension CollectionHeaderCell {
	func setConstraints() {
		let vStack = UIStackView()
		vStack.axis = .vertical
		vStack.alignment = .leading
		vStack.spacing = 13
		[
			titleLabel,
			authorLabel,
			descriptionLabel
		].forEach { vStack.addArrangedSubview($0) }
		vStack.setCustomSpacing(5, after: authorLabel)

		let view = UIView()
		view.addSubview(vStack)
		vStack.makeEqualToSuperview(insets: .init(horizontal: Theme.spacing(usage: .standard2), vertical: .zero))

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

	func makeTitleLabel() -> UILabel {
		let label = UILabel()
		label.textColor = Theme.color(usage: .main)
		label.font = Theme.font(style: .title2)

		return label
	}

	func makeAuthorLabel() -> UILabel {
		let label = UILabel()

		let tap = UITapGestureRecognizer(target: self, action: #selector(handleOnTapAuthor))
		label.addGestureRecognizer(tap)
		label.isUserInteractionEnabled = true

		return label
	}

	func makeDescriptionLabel() -> UILabel {
		let label = UILabel()
		label.textColor = Theme.color(usage: .main)
		label.font = Theme.font(style: .footnote)
		label.numberOfLines = .zero

		return label
	}
}

private extension CollectionHeaderCellModel {
	enum Appearance {
		static let authorTextPrefix = "Автор колллекции:"
	}

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
