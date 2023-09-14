import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
	private let viewModel: SplashViewModel

	// MARK: - UI
	private lazy var logoImageView: UIImageView = ImageViewFactory.makeImageView(
		image: Theme.image(kind: .logo)
	)

	// MARK: - Inits

	init(viewModel: SplashViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("SplashViewController deinit")
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		applyStyle()
		setConstraints()

		bind(to: viewModel)
		viewModel.viewIsReady()
	}
}

// MARK: - Bind

private extension SplashViewController {
	func bind(to viewModel: SplashViewModel) {
		viewModel.isLoading.observe(on: self) { isLoading in
			isLoading ? ProgressHUD.show() : ProgressHUD.dismiss()
		}
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
