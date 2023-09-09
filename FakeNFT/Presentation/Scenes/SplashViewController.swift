import UIKit

final class SplashViewController: UIViewController {
	// MARK: - UI
	private lazy var logoImageView: UIImageView = ImageViewFactory.makeImageView(
		image: Theme.image(kind: .logo)
	)

	override func viewDidLoad() {
		super.viewDidLoad()

		applyStyle()
		setConstraints()
	}
}

// MARK: - UI
private extension SplashViewController {
	func applyStyle() {
		view.backgroundColor = Theme.color(usage: .white)
	}

	func setConstraints() {
		view.addSubview(logoImageView)
		logoImageView.makeConstraints { $0.size(Appearance.logoSize) }
		logoImageView.makeEqualToSuperviewCenterToSafeArea()
	}
}

private extension SplashViewController {
	enum Appearance {
		static let logoSize = CGSize(width: 75, height: 78)
	}
}
