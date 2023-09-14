import UIKit

final class RatingView: UIView {

	private var stars: [UIImageView]

	// MARK: - Inits
	override init(frame: CGRect) {
		stars = (1...5).map { _ in
			let view = UIImageView()
			view.image = Theme.image(kind: .star)
			return view
		}
		super.init(frame: frame)

		applyStyle()
		setConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Update
extension RatingView {
	@discardableResult
	func update(with data: Int) -> Self {
		stars.enumerated().forEach { offset, star in
			star.tintColor = data > offset
			? Theme.color(usage: .yellow)
			: Theme.color(usage: .lightGray)
		}
		return self
	}
}

// MARK: - UI
private extension RatingView {
	func applyStyle() {
		backgroundColor = .clear
	}
	func setConstraints() {
		let stack = UIStackView(arrangedSubviews: stars)
		stack.alignment = .center
		stack.spacing = 2

		addSubview(stack)
		stack.makeEqualToSuperview()
	}
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct RatingViewPreviews: PreviewProvider {
	static var previews: some View {
		let rating0 = RatingView().update(with: 0)
		let rating1 = RatingView().update(with: 1)
		let rating2 = RatingView().update(with: 2)
		let rating3 = RatingView().update(with: 3)
		let rating4 = RatingView().update(with: 4)
		let rating5 = RatingView().update(with: 5)

		return Group {
			VStack(spacing: 10) {
				rating0.preview().frame(width: 68, height: 12)
				rating1.preview().frame(width: 68, height: 12)
				rating2.preview().frame(width: 68, height: 12)
				rating3.preview().frame(width: 68, height: 12)
				rating4.preview().frame(width: 68, height: 12)
				rating5.preview().frame(width: 68, height: 12)
			}
			.preferredColorScheme(.light)
		}
	}
}
#endif
