import UIKit
import WebKit

final class WebViewController: UIViewController, WKNavigationDelegate {

	private let viewModel: WebViewModel

	// MARK: - UI Elements
	private lazy var goBackButton: UIButton = makeGoBackButton()
	private lazy var webView: WKWebView = makeWebView()

	// MARK: - Inits

	init(viewModel: WebViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		applyStyle()
		setConstraints()

		bind(to: viewModel)
		viewModel.viewIsReady()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: animated)
		tabBarController?.tabBar.isHidden = true
		extendedLayoutIncludesOpaqueBars = true
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.setNavigationBarHidden(false, animated: animated)
		tabBarController?.tabBar.isHidden = false
		extendedLayoutIncludesOpaqueBars = false
	}
}

// MARK: - Bind

private extension WebViewController {
	func bind(to viewModel: WebViewModel) {
		viewModel.url.observe(on: self) { [weak self] url in
			guard let url = url else { return }
			self?.webView.load(URLRequest(url: url))
		}
	}
}

// MARK: - Actions
private extension WebViewController {
	@objc func didTapGoBackButton(_ sender: Any) {
		viewModel.didUserDo(request: .goBack)
	}
}

// MARK: - UI
private extension WebViewController {
	func applyStyle() {
		view.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
		[
			webView,
			goBackButton
		].forEach { view.addSubview($0) }
		webView.makeEqualToSuperviewToSafeArea(insets: .init(top: 42))
		goBackButton.makeConstraints { $0.size(Theme.size(kind: .small)) }
		goBackButton.makeConstraints { make in
			[
				make.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 9),
				make.topAnchor.constraint(equalTo: view.topAnchor, constant: 55)
			]
		}
	}
}

// MARK: - UI make
private extension WebViewController {
	func makeGoBackButton() -> UIButton {
		let button = UIButton(type: .custom)
		button.setImage(Theme.image(kind: .goBack), for: .normal)
		button.tintColor = Theme.color(usage: .black)
		button.event = { [weak self] in self?.viewModel.didUserDo(request: .goBack) }

		return button
	}

	func makeWebView() -> WKWebView {
		let webView = WKWebView()
		webView.backgroundColor = .clear
		webView.navigationDelegate = self
		webView.allowsBackForwardNavigationGestures = true

		// избегаю эффекта резинки - не нравится в темной теме белый фон
		webView.scrollView.bounces = false
		// но на нижней границе только так
		webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)

		return webView
	}
}
