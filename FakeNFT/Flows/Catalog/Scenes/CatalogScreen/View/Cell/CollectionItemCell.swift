import UIKit

final class CollectionItemCell: UITableViewCell {
	// MARK: - UI Elements
	fileprivate lazy var coverImageView: UIImageView = makeCoverImageView()
	fileprivate lazy var descriptionLabel: UILabel = makeDescriptionLabel()

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

		coverImageView.image = nil
		descriptionLabel.text = nil
	}
}

// MARK: - Data model for cell

struct CollectionItemCellModel {
	let image: String
	let description: String
}

// MARK: - ICellViewModel

extension CollectionItemCellModel: ICellViewModel {
	func setup(cell: CollectionItemCell) {
		let newWidth = UIScreen.main.bounds.width - 32

		cell.coverImageView.image = UIImage(named: image)?
			.resize(withWidth: newWidth)
		cell.descriptionLabel.text = description
	}
}

// MARK: - UI
private extension CollectionItemCell {
	func applyStyle() {
		contentView.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
		let vStack = UIStackView()
		vStack.axis = .vertical
		vStack.spacing = Theme.spacing(usage: .standardHalf)
		[
			coverImageView,
			descriptionLabel
		].forEach { vStack.addArrangedSubview($0) }
		coverImageView.makeConstraints { make in
			[
				make.heightAnchor.constraint(equalToConstant: 140)
			]
		}
		descriptionLabel.makeConstraints { make in
			[
				make.heightAnchor.constraint(equalToConstant: 22)
			]
		}
		contentView.addSubview(vStack)
		vStack.makeEqualToSuperview(insets: .init(top: 0, left: 16, bottom: 21, right: 16))
	}
}

// MARK: - UI make
private extension CollectionItemCell {
	func makeCoverImageView() -> UIImageView {
		let imageView = UIImageView()
		imageView.contentMode = .top
		imageView.layer.cornerRadius = Theme.dimension(kind: .largeRadius)
		imageView.layer.masksToBounds = true

		return imageView
	}
	func makeDescriptionLabel() -> UILabel {
		let label = UILabel()
		label.font = Theme.font(style: .headline)
		label.textColor = Theme.color(usage: .main)

		return label
	}
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct CatalogItemCellPreviews: PreviewProvider {
	static func makeCell(model: CollectionItemCellModel) -> UIView {
		let cell = CollectionItemCell()
		model.setup(cell: cell)
		return cell
	}
	static var previews: some View {
		let model = CollectionItemCellModel(image: "Peach", description: "Peach (11)")
		let cell = makeCell(model: model)

		return Group {
			VStack(spacing: 0) {
				cell.preview().frame(height: 187)
			}
		}
	}
}
#endif

extension CollectionItemCellModel {
	static let defaultCollections: [CollectionItemCellModel] =
	[
		.init(image: "Beige", description: "Beige (21)"),
		.init(image: "Blue", description: "Blue (5)"),
		.init(image: "Gray", description: "Gray (19)"),
		.init(image: "Green", description: "Green (3)"),
		.init(image: "Peach", description: "Peach (11)"),
		.init(image: "Pink", description: "Pink (14)"),
		.init(image: "White", description: "White (7)"),
		.init(image: "Yellow", description: "Yellow (8)"),
		.init(image: "Brown", description: "Brown (7)")
	]

	static let domainCollections: [Collection] = [
		.init(
			id: "1",
			name: "Beige",
			description: "A series of one-of-a-kind NFTs featuring historic moments in sports history.",
			cover: nil,
			nfts: [],
			authorID: "6"
		),
		.init(
			id: "2",
			name: "Blue",
			description: "A collection of virtual trading cards featuring popular characters from movies and TV shows.",
			cover: nil,
			nfts: [],
			authorID: "9"
		),
		.init(
			id: "3",
			name: "Gray",
			description: "A set of limited edition digital stamps featuring famous landmarks from around the world.",
			cover: nil,
			nfts: [],
			authorID: "12"
		),
		.init(
			id: "4",
			name: "Green",
			description: "A collection of unique 3D sculptures that can be displayed in virtual reality.",
			cover: nil,
			nfts: [],
			authorID: "15"
		)
	]
}
