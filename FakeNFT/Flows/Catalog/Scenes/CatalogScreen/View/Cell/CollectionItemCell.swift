import UIKit

class CollectionItemCell: UITableViewCell {
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
		let newImage = resizeImage(
			image: UIImage(named: image),
			newWidth: newWidth
		)

		cell.coverImageView.image = newImage
		cell.descriptionLabel.text = description
	}

	func resizeImage(image: UIImage?, newWidth: CGFloat) -> UIImage {
		guard let image = image else { return UIImage() }

		let scale = newWidth / image.size.width
		let newHeight = image.size.height * scale
		UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
		image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return newImage ?? image
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
		vStack.makeEqualToSuperview(insets: .init(top: 0, left: 16, bottom: 20, right: 16))
	}
}

// MARK: - UI make
private extension CollectionItemCell {
	func makeCoverImageView() -> UIImageView {
		let imageView = UIImageView()
		imageView.contentMode = .top // .scaleAspectFill
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
				cell.preview().frame(height: 186)
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

	static let mainCollections: [CollectionItemViewModel] = [
		.init(id: "Beige", title: "Beige", nftsCount: 21, cover: nil),
		.init(id: "Blue", title: "Blue", nftsCount: 5, cover: nil),
		.init(id: "Gray", title: "Gray", nftsCount: 19, cover: nil),
		.init(id: "Green", title: "Green", nftsCount: 3, cover: nil),
		.init(id: "Peach", title: "Peach", nftsCount: 11, cover: nil),
		.init(id: "Pink", title: "Pink", nftsCount: 14, cover: nil),
		.init(id: "White", title: "White", nftsCount: 7, cover: nil),
		.init(id: "Yellow", title: "Yellow", nftsCount: 8, cover: nil),
		.init(id: "Brown", title: "Brown", nftsCount: 7, cover: nil),
	]
}
