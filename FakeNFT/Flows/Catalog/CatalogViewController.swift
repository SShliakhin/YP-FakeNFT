import UIKit
import ProgressHUD

final class CatalogViewController: UIViewController {
	private lazy var titleLabel: UILabel = makeTitleLabel()

	// MARK: - Inits

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		setup()
		applyStyle()
		setConstraints()
	}
}

// MARK: - UI
private extension CatalogViewController {
	func setup() {}
	func applyStyle() {
		view.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
		[
			titleLabel
		].forEach { view.addSubview($0) }

		titleLabel.makeEqualToSuperviewCenterToSafeArea()
	}
}

// MARK: - UI make
private extension CatalogViewController {
	func makeTitleLabel() -> UILabel {
		let label = UILabel()
		label.text = Appearance.titleLabelText
		label.textAlignment = .center
		label.textColor = Theme.color(usage: .green)
		label.font = Theme.font(style: .title1)

		return label
	}
}

// MARK: - Appearance
private extension CatalogViewController {
	enum Appearance {
		static let titleLabelText = "Not implemented yet"
	}
}
