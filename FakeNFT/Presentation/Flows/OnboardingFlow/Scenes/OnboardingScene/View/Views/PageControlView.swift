import UIKit

final class PageControlView: UIView {
	private var paginators: [UIButton] = []
	var onTap: ((Int) -> Void)

	// MARK: - Inits -
	init(count: Int, onTap: @escaping ((Int) -> Void)) {
		self.onTap = onTap
		super.init(frame: .zero)

		for index in 0 ..< count {
			let button = ButtonFactory.makeLabelButton(
				backgroundColor: Theme.color(usage: .allDayWhite),
				cornerRadius: 2
			) { [weak self] in
				self?.onTap(index)
			}
			paginators.append(button)
		}

		let container = UIView()
		container.backgroundColor = .clear
		addSubview(container)
		container.makeEqualToSuperview()

		let stack = UIStackView(arrangedSubviews: paginators)
		stack.spacing = Theme.spacing(usage: .standard)
		stack.distribution = .fillEqually
		stack.alignment = .center

		container.addSubview(stack)
		stack.makeEqualToSuperview(
			insets: .init(
				horizontal: Theme.spacing(usage: .standard2),
				vertical: 12
			)
		)
	}

	override var intrinsicContentSize: CGSize {
		return .init(width: UIScreen.main.bounds.width, height: 28)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Update
extension PageControlView {
	@discardableResult
	func update(with data: Int) -> Self {
		paginators.enumerated().forEach { offset, paginator in
			paginator.backgroundColor = data > offset
			? Theme.color(usage: .gray)
			: Theme.color(usage: .white)
			if data == offset {
				paginator.backgroundColor = Theme.color(usage: .black)
			}
		}
		return self
	}
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct PaginationViewPreviews: PreviewProvider {
	static var previews: some View {
		let pagination = PageControlView(count: 3, onTap: { _ in
			print("Тест")
		}).update(with: 2)

		return Group {
			VStack(spacing: 10) {
				pagination.preview().frame(
					width: UIScreen.main.bounds.width,
					height: 28
				)
			}
			.preferredColorScheme(.light)
		}
	}
}
#endif
