import UIKit
import Kingfisher

final class CollectionItemCell: UITableViewCell {
	fileprivate static let imageWidth = UIScreen.main.bounds.width - 32
	fileprivate static let imagePlaceholder = Theme.image(kind: .imagePlaceholder)

	// MARK: - UI Elements
	lazy var coverImageView: UIImageView = makeCoverImageView()
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

		coverImageView.kf.cancelDownloadTask()
	}
}

// MARK: - Data model for cell

struct CollectionItemCellModel {
	let imageURL: URL?
	let description: String
}

// MARK: - ICellViewModel

extension CollectionItemCellModel: ICellViewModel {
	func setup(cell: CollectionItemCell) {

		cell.descriptionLabel.text = description
		cell.coverImageView.kf.setImage(
			with: imageURL,
			placeholder: CollectionItemCell.imagePlaceholder,
			options: [.transition(.fade(0.2))]
		) { [weak cell] result in
			guard let cell = cell else { return }
			switch result {
			case .success(let value):
				cell.coverImageView.image = value.image
					.resize(withWidth: CollectionItemCell.imageWidth)
			case .failure:
				cell.coverImageView.image = CollectionItemCell.imagePlaceholder
				cell.contentMode = .center
			}
		}
	}
}

// MARK: - UI
private extension CollectionItemCell {
	func applyStyle() {
		contentView.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
		let vStack = UIStackView(arrangedSubviews: [coverImageView, descriptionLabel])
		vStack.axis = .vertical
		vStack.spacing = Theme.spacing(usage: .standardHalf)

		coverImageView.makeConstraints { [$0.heightAnchor.constraint(equalToConstant: 140)] }
		descriptionLabel.makeConstraints { [$0.heightAnchor.constraint(equalToConstant: 22)] }

		contentView.addSubview(vStack)
		vStack.makeEqualToSuperview(insets: .init(top: .zero, left: 16, bottom: 21, right: 16))
	}
}

// MARK: - UI make
private extension CollectionItemCell {
	func makeCoverImageView() -> UIImageView {
		let imageView = UIImageView()
		imageView.contentMode = .top
		imageView.layer.cornerRadius = Theme.dimension(kind: .largeRadius)
		imageView.layer.masksToBounds = true

		imageView.kf.indicatorType = .activity

		return imageView
	}
	func makeDescriptionLabel() -> UILabel {
		let label = UILabel()
		label.font = Theme.font(style: .headline)
		label.textColor = Theme.color(usage: .main)

		return label
	}
}
