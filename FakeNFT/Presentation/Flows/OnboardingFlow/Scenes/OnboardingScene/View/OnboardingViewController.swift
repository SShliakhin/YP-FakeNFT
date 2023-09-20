import UIKit

final class OnboardingViewController: UIViewController {
	private let viewModel: OnboardingViewModel
	private let pageViewController: PageViewController

	// MARK: - UI
	private lazy var pageControlView = PageControlView(count: viewModel.numberOfPages) { [weak self] pageIndex in
		self?.viewModel.didUserDo(request: .showPage(pageIndex))
	}
	private lazy var closeButton = ButtonFactory.makeButton(
		image: Theme.image(kind: .close),
		tintColor: Theme.color(usage: .allDayWhite)
	) { [weak self] in
		self?.viewModel.didUserDo(request: .didTapActionButton)
	}
	private lazy var completionButton = ButtonFactory.makeLabelButton(
		label: LabelFactory.makeLabel(
			font: Theme.font(style: .headline),
			text: viewModel.completionButtonTitle,
			textColor: Theme.color(usage: .black)
		),
		backgroundColor: Theme.color(usage: .white),
		cornerRadius: Theme.dimension(kind: .cornerRadius)
	) { [weak self] in
		// чтобы успеть увидеть анимацию нажатия кнопки
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
			self?.viewModel.didUserDo(request: .didTapActionButton)
		}
	}

	// MARK: - Inits -

	init(viewModel: OnboardingViewModel, pageViewController: PageViewController) {
		self.viewModel = viewModel
		self.pageViewController = pageViewController

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

		setup()
		setConstraints()

		bind(to: viewModel)
		viewModel.viewIsReady()
	}
}

// MARK: - Bind -

private extension OnboardingViewController {
	func bind(to viewModel: OnboardingViewModel) {
		viewModel.renderMe.observe(on: self) { [weak self] _ in
			self?.renderViewModel()
		}
	}

	func renderViewModel() {
		pageControlView.update(with: viewModel.pageNumber)
		pageViewController.update(pageNumber: viewModel.pageNumber)

		closeButton.isHidden = !viewModel.shouldShowCloseButton
		completionButton.isHidden = !viewModel.shouldShowCompletionButton
	}
}

// MARK: - UI
private extension OnboardingViewController {
	func setup() {
		// внедряем к себе pageVC
		addChild(pageViewController)
		view.addSubview(pageViewController.view)
		pageViewController.didMove(toParent: self)

		completionButton.addTarget(self, action: #selector(addClickAnimation), for: .touchUpInside)
	}

	func setConstraints() {
		[
			closeButton,
			completionButton,
			pageControlView
		].forEach { view.addSubview($0) }

		closeButton.makeConstraints { make in
			[
				make.topAnchor.constraint(
					equalTo: view.safeAreaLayoutGuide.topAnchor,
					constant: Appearance.closeButtonTopInset
				),
				make.trailingAnchor.constraint(
					equalTo: view.safeAreaLayoutGuide.trailingAnchor,
					constant: -Appearance.closeButtonTrailingInset
				)
			]
		}
		completionButton.makeConstraints { make in
			[
				make.heightAnchor.constraint(equalToConstant: Appearance.completionButtonHeight),
				make.bottomAnchor.constraint(
					equalTo: view.bottomAnchor,
					constant: -Appearance.completionButtonBottomInset
				),
				make.leadingAnchor.constraint(
					equalTo: view.safeAreaLayoutGuide.leadingAnchor,
					constant: Theme.spacing(usage: .standard2)
				),
				make.trailingAnchor.constraint(
					equalTo: view.safeAreaLayoutGuide.trailingAnchor,
					constant: -Theme.spacing(usage: .standard2)
				)
			]
		}
		pageControlView.makeConstraints { make in
			[
				make.heightAnchor.constraint(equalToConstant: Appearance.pageControlViewHeight),
				make.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
				make.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
				make.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
			]
		}
	}
}

private extension OnboardingViewController {
	enum Appearance {
		static let completionButtonHeight = 60.0
		static let completionButtonBottomInset = 76.0

		static let closeButtonTopInset = 2.0
		static let closeButtonTrailingInset = 9.0

		static let pageControlViewHeight = 28.0
	}

	@objc func addClickAnimation(sender: UIButton) { sender.addClickAnimation() }
}
