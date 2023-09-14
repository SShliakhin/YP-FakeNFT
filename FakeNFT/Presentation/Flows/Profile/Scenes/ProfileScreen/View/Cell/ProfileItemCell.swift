import UIKit

final class ProfileItemCell: UITableViewCell {

	// MARK: - UI Elements
	fileprivate lazy var descriptionLabel: UILabel = LabelFactory.makeLabel(
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

		descriptionLabel.text = nil
	}
}

// MARK: - Data model for cell

struct ProfileItemCellModel {
	let description: String
}

// MARK: - ICellViewModel

extension ProfileItemCellModel: ICellViewModel {
	func setup(cell: ProfileItemCell) {
		cell.descriptionLabel.text = description
	}
}

// MARK: - UI
private extension ProfileItemCell {
	func applyStyle() {
		contentView.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
		let showDetail = UIImageView(image: Theme.image(kind: .showDetail))
		showDetail.tintColor = Theme.color(usage: .black)

		let hStack = UIStackView(arrangedSubviews: [descriptionLabel, showDetail])
		hStack.distribution = .equalSpacing
		hStack.alignment = .center

		contentView.addSubview(hStack)
		hStack.makeEqualToSuperview(insets: .init(all: Theme.spacing(usage: .standard2)))
	}
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct ProfileItemCellProvider: PreviewProvider {
	static var previews: some View {
		let modelMyNFT = ProfileItemCellModel(description: "Мои NFT  (112)")
		let cellMyNFT = ProfileItemCell()
		modelMyNFT.setup(cell: cellMyNFT)
		let modelFavorites = ProfileItemCellModel(description: "Избранные NFT  (11)")
		let cellFavorites = ProfileItemCell()
		modelFavorites.setup(cell: cellFavorites)
		let modelAbout = ProfileItemCellModel(description: "О разработчике")
		let cellAbout = ProfileItemCell()
		modelAbout.setup(cell: cellAbout)

		return Group {
			VStack(spacing: 0) {
				cellMyNFT.preview().frame(width: 375, height: 54)
				cellFavorites.preview().frame(width: 375, height: 54)
				cellAbout.preview().frame(width: 375, height: 54)
			}.preferredColorScheme(.dark)
			VStack(spacing: 0) {
				cellMyNFT.preview().frame(width: 375, height: 54)
				cellFavorites.preview().frame(width: 375, height: 54)
				cellAbout.preview().frame(width: 375, height: 54)
			}.preferredColorScheme(.light)
		}
	}
}
#endif
