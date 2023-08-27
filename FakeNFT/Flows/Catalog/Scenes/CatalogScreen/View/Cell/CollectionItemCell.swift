import UIKit
import Kingfisher

final class CollectionItemCell: UITableViewCell {
	fileprivate var imageUrl: URL? {
		didSet { updateCoverImageByUrl(imageUrl) }
	}

	fileprivate var descriptionText: String = "" {
		didSet { descriptionLabel.text = descriptionText }
	}

	// MARK: - UI Elements
	private lazy var coverImageView: UIImageView = makeCoverImageView()
	private lazy var descriptionLabel: UILabel = makeDescriptionLabel()

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

		coverImageView.kf.cancelDownloadTask()

		coverImageView.image = nil
		descriptionLabel.text = nil
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
		cell.imageUrl = imageURL
		cell.descriptionText = description
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

		coverImageView.makeConstraints {
			[$0.heightAnchor.constraint(equalToConstant: Appearance.coverHeight)]
		}
		descriptionLabel.makeConstraints {
			[$0.heightAnchor.constraint(equalToConstant: Appearance.labelHeight)]
		}

		contentView.addSubview(vStack)
		vStack.makeEqualToSuperview(insets: Appearance.contentInsets)
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

private extension CollectionItemCell {
	enum Appearance {
		static let imagePlaceholder = Theme.image(kind: .imagePlaceholder)
		static let imageWidth = UIScreen.main.bounds.width - 32.0
		static let coverHeight = 140.0
		static let labelHeight = 22.0
		static let contentInsets: UIEdgeInsets = .init(
			top: .zero,
			left: 16,
			bottom: 21,
			right: 16
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
