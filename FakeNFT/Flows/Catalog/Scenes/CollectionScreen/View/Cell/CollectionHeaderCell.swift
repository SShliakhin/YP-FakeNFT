import UIKit

final class CollectionHeaderCell: UICollectionViewCell {
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
	}
}

// MARK: - Actions
private extension CollectionHeaderCell {
	@objc
	func handleOnTapAuthor() {
		onTapAuthor?()
	}
}

// MARK: - Data model for cell

struct CollectionHeaderCellModel {
	let coverImageString: String
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

		let newWidth = UIScreen.main.bounds.width

		cell.coverImageView.image = UIImage(named: coverImageString)?
			.resize(withWidth: newWidth)
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

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct CollectionHeaderCellPreviews: PreviewProvider {
	static var previews: some View {

		let view = CollectionHeaderCell()
		let model = CollectionHeaderCellModel(
			coverImageString: "Peach",
			title: "Peach",
			author: "John Doe",
			description: "Персиковый — как облака над закатным солнцем в океане. В этой коллекции совмещены трогательная нежность и живая игривость сказочных зефирных зверей.",
			onTapAuthor: nil
		)
		model.setup(cell: view)
		return Group {
			view.preview().frame(height: 468)
		}
		.preferredColorScheme(.light)
	}
}
#endif

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
