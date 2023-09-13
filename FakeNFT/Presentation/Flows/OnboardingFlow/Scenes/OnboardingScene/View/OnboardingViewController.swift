import UIKit

final class OnboardingViewController: UIViewController {
	private let viewModel: OnboardingViewModel

	// MARK: - UI
	private lazy var actionButton: UIButton = makeActionButton()

	// MARK: - Inits

	init(viewModel: OnboardingViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("OnboardingViewController deinit")
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		applyStyle()
		setConstraints()
	}
}

// MARK: - UI
private extension OnboardingViewController {
	func applyStyle() {
		title = viewModel.titleScreen
		view.backgroundColor = Theme.color(usage: .white)
	}

	func setConstraints() {
		view.addSubview(actionButton)
		actionButton.makeConstraints { $0.size(Appearance.buttonSize) }
		actionButton.makeEqualToSuperviewCenterToSafeArea()
	}
}

// MARK: - UI make
private extension OnboardingViewController {
	func makeActionButton() -> UIButton {
		let button = UIButton(type: .close)
		button.event = { [weak self] in self?.viewModel.didUserDo(request: .didTapActionButton) }

		return button
	}
}

private extension OnboardingViewController {
	enum Appearance {
		static let buttonSize = CGSize(width: 75, height: 44)
	}
}
