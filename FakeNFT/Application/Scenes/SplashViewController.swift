import UIKit

final class SplashViewController: UIViewController {
	// MARK: - UI
	private lazy var logoImageView: UIImageView = makeLogoImageView()

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

// MARK: - UI make
private extension SplashViewController {
	func makeLogoImageView() -> UIImageView {
		let imageView = UIImageView(image: Theme.image(kind: .logo))
		imageView.contentMode = .scaleAspectFit

		return imageView
	}
}

private extension SplashViewController {
	enum Appearance {
		static let logoSize = CGSize(width: 75, height: 78)
	}
}
