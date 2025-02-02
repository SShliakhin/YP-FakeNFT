import UIKit

struct NavBarInputData {
	let title: String
	let isGoBackButtonHidden: Bool
	let isSortButtonHidden: Bool
	let onTapGoBackButton: (() -> Void)?
	let onTapSortButton: (() -> Void)?
}

final class NavBarView: UIView {

	private lazy var titleLabel: UILabel = LabelFactory.makeLabel(
		font: Theme.font(style: .headline)
	)
	private lazy var goBackButton: UIButton = ButtonFactory.makeButton(
		image: Theme.image(kind: .goBack)
	)
	private lazy var sortButton: UIButton = ButtonFactory.makeButton(
		image: Theme.image(kind: .sortIcon)
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

		return self
	}
}

// MARK: - UI
private extension NavBarView {
	func applyStyle() {
		backgroundColor = .clear
	}
	func setConstraints() {
		let containerView = UIView(
			subviews: titleLabel, goBackButton, sortButton
		)

		titleLabel.makeEqualToSuperviewCenter()
		goBackButton.makeConstraints { make in
			[
				make.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
				make.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
			]
		}
		sortButton.makeConstraints { make in
			[
				make.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
				make.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
			]
		}

		addSubview(containerView)
		containerView.makeEqualToSuperview(insets: Appearance.contentInsets)
	}
}

private extension NavBarView {
	enum Appearance {
		static let contentInsets: UIEdgeInsets = .init(
			horizontal: 9,
			vertical: .zero
		)
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
