import UIKit

final class OnboardingViewController: UIViewController {
	private let viewModel: OnboardingViewModel

	// MARK: - UI
	private lazy var imageView = ImageViewFactory.makeImageView()
	private lazy var gradientView = GradientView()
		.update(with: GradientView.OnboardingPageLayer)
	private lazy var titleLabel = LabelFactory.makeLabel(
		font: Theme.font(style: .title1),
		textColor: Theme.color(usage: .allDayWhite)
	)
	private lazy var textLabel = LabelFactory.makeLabel(
		font: Theme.font(style: .subhead),
		textColor: Theme.color(usage: .allDayWhite),
		numberOfLines: .zero
	)

	private lazy var pageControlView = PageControlView(count: viewModel.numberOfPages) { [weak self] index in
		self?.viewModel.didUserDo(request: .showPage(index))
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
	) {
		// чтобы успеть увидеть анимацию нажатия кнопки
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
			self?.viewModel.didUserDo(request: .didTapActionButton)
		}
	}

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

		bind(to: viewModel)
		viewModel.viewIsReady()

		completionButton.addTarget(self, action: #selector(addClickAnimation), for: .touchUpInside)
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		if viewModel.shouldShowCloseButton {
			view.addSubview(closeButton)
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
		} else {
			closeButton.removeFromSuperview()
		}

		if viewModel.shouldShowCompletionButton {
			view.addSubview(completionButton)
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
		} else {
			completionButton.removeFromSuperview()
		}
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
		imageView.image = Theme.image(kind: viewModel.imageAsset)
		pageControlView.update(with: viewModel.pageNumber)
		titleLabel.text = viewModel.title
		textLabel.text = viewModel.text
		textLabel.lineBreakMode = .byWordWrapping
		if viewModel.shouldShowCompletionButton {
			completionButton.setTitle(viewModel.completionButtonTitle, for: .normal)
		}
	}
}

// MARK: - UI
private extension OnboardingViewController {
	func applyStyle() {}

	func setConstraints() {
		let stackView = UIStackView(arrangedSubviews: [titleLabel, textLabel])
		stackView.axis = .vertical
		stackView.spacing = Appearance.textSpacing

		[
			imageView,
			gradientView,
			stackView,
			pageControlView
		].forEach { view.addSubview($0) }

		imageView.makeEqualToSuperview()
		gradientView.makeEqualToSuperview()

		stackView.makeConstraints { make in
			[
				make.centerYAnchor.constraint(
					equalTo: view.safeAreaLayoutGuide.topAnchor,
					constant: view.frame.height / (Appearance.textYOffsetCenterInitialValue - CGFloat(viewModel.pageNumber))
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

		static let textSpacing = 12.0
		static let textYOffsetCenterInitialValue = 4.0

		static let pageControlViewHeight = 28.0
	}

	@objc func addClickAnimation(sender: UIButton) { sender.addClickAnimation() }
}
