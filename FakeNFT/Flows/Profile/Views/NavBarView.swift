import UIKit

struct NavBarInputData {
	let title: String
	let isGoBackButtonHidden: Bool
	let isSortButtonHidden: Bool
	let onTapGoBackButton: (() -> Void)?
	let onTapSortButton: (() -> Void)?
}

final class NavBarView: UIView {

	private lazy var titleLabel: UILabel = makeTitleLabel()
	private lazy var goBackButton: UIButton = makeGoBackButton()
	private lazy var sortButton: UIButton = makeSortButton()

	// MARK: - Inits
	override init(frame: CGRect) {
		super.init(frame: frame)

		applyStyle()
		setConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Update
extension NavBarView {
	@discardableResult
	func update(with data: NavBarInputData) -> Self {
		titleLabel.text = data.title
		goBackButton.isHidden = data.isGoBackButtonHidden
		sortButton.isHidden = data.isSortButtonHidden
		goBackButton.event = data.onTapGoBackButton
		sortButton.event = data.onTapSortButton

		setConstraints()

		return self
	}
}

// MARK: - UI
private extension NavBarView {
	func applyStyle() {
		backgroundColor = .clear
	}
	func setConstraints() {
		let stack = UIStackView(
			arrangedSubviews: [
				goBackButton,
				titleLabel,
				sortButton
			]
		)
		stack.alignment = .center
		stack.spacing = Theme.spacing(usage: .standard3)
		stack.setCustomSpacing(Appearance.stackCustomSpacing, after: titleLabel)

		goBackButton.makeConstraints { $0.size(Appearance.goBackButtonSize) }
		sortButton.makeConstraints { $0.size(Appearance.sortButtonSize) }

		if goBackButton.isHidden || sortButton.isHidden {
			titleLabel.makeConstraints {
				[$0.centerXAnchor.constraint(equalTo: stack.centerXAnchor)]
			}
		}

		addSubview(stack)
		stack.makeEqualToSuperview(insets: Appearance.contentInsets)
	}
}

// MARK: - UI make
private extension NavBarView {
	func makeTitleLabel() -> UILabel {
		let label = UILabel()
		label.textColor = Theme.color(usage: .main)
		label.font = Theme.font(style: .headline)
		label.textAlignment = .center

		return label
	}

	func makeGoBackButton() -> UIButton {
		let button = UIButton(type: .custom)
		button.setImage(Theme.image(kind: .goBack), for: .normal)
		button.tintColor = Theme.color(usage: .black)

		return button
	}

	func makeSortButton() -> UIButton {
		let button = UIButton(type: .custom)
		button.setImage(Theme.image(kind: .sortIcon), for: .normal)
		button.tintColor = Theme.color(usage: .black)

		return button
	}
}

private extension NavBarView {
	enum Appearance {
		static let contentInsets: UIEdgeInsets = .init(
			horizontal: 9,
			vertical: .zero
		)
		static let stackCustomSpacing = 6.0
		static let goBackButtonSize: CGSize = .init(width: 24, height: 24)
		static let sortButtonSize: CGSize = .init(width: 42, height: 42)
	}
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct NavBarViewPreviews: PreviewProvider {
	static var previews: some View {
		let data = NavBarInputData(
			title: "Мои NFT",
			isGoBackButtonHidden: false,
			isSortButtonHidden: false,
			onTapGoBackButton: nil,
			onTapSortButton: nil
		)
		let data2 = NavBarInputData(
			title: "Мои NFT",
			isGoBackButtonHidden: false,
			isSortButtonHidden: true,
			onTapGoBackButton: nil,
			onTapSortButton: nil
		)
		let data3 = NavBarInputData(
			title: "Мои NFT",
			isGoBackButtonHidden: true,
			isSortButtonHidden: false,
			onTapGoBackButton: nil,
			onTapSortButton: nil
		)
		let navBarView = NavBarView().update(with: data)
		let navBarView2 = NavBarView().update(with: data2)
		let navBarView3 = NavBarView().update(with: data3)

		return Group {
			VStack(spacing: 10) {
				navBarView.preview()
					.frame(width: 375, height: 42)
				navBarView2.preview()
					.frame(width: 375, height: 42)
				navBarView3.preview()
					.frame(width: 375, height: 42)
			}
			.preferredColorScheme(.light)
			VStack(spacing: 10) {
				navBarView.preview()
					.frame(width: 375, height: 42)
			}
			.preferredColorScheme(.dark)
		}
	}
}
#endif
