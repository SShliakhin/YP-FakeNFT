import UIKit

final class OnboardingPageViewController: UIViewController {
	private let page: OnboardingPageData

	// MARK: - UI
	private lazy var imageView = ImageViewFactory.makeImageView(
		image: Theme.image(kind: page.imageAssetValue)
	)
	private lazy var gradientView = GradientView()
		.update(with: GradientView.OnboardingPageLayer)
	private lazy var titleLabel = LabelFactory.makeLabel(
		font: Theme.font(style: .title1),
		text: page.titleValue,
		textColor: Theme.color(usage: .allDayWhite)
	)
	private lazy var textLabel = LabelFactory.makeLabel(
		font: Theme.font(style: .subhead),
		text: page.textValue,
		textColor: Theme.color(usage: .allDayWhite),
		numberOfLines: .zero
	)

	// MARK: - Inits

	init(page: OnboardingPageData) {
		self.page = page
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("OnboardingPageViewController deinit")
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		setConstraints()
	}
}

private extension OnboardingPageViewController {
	func setConstraints() {
		let stackView = UIStackView(arrangedSubviews: [titleLabel, textLabel])
		stackView.axis = .vertical
		stackView.spacing = Appearance.textSpacing

		[
			imageView,
			gradientView,
			stackView
		].forEach { view.addSubview($0) }

		imageView.makeEqualToSuperview()
		gradientView.makeEqualToSuperview()

		stackView.makeConstraints { make in
			[
				make.centerYAnchor.constraint(
					equalTo: view.safeAreaLayoutGuide.bottomAnchor,
					constant: -(view.frame.height / Appearance.textYOffsetDividerValue)
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
	}

	enum Appearance {
		static let textSpacing = 12.0
		static let textYOffsetDividerValue = 4.0
	}
}
