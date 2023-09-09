import UIKit
import WebKit
import ProgressHUD

final class WebViewController: UIViewController, WKNavigationDelegate {
	private let viewModel: WebViewModel

	// MARK: - UI Elements
	private lazy var navBarView = NavBarView()
		.update(with: NavBarInputData(
			title: "",
			isGoBackButtonHidden: false,
			isSortButtonHidden: true,
			onTapGoBackButton: { [weak self] in self?.viewModel.didUserDo(request: .goBack) },
			onTapSortButton: nil
		))
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

		hideNavTabBars(animated)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		if webView.isLoading {
			webView.stopLoading()
		}

		showNavTabBars(animated)
	}
}

// MARK: - Bind

private extension WebViewController {
	func bind(to viewModel: WebViewModel) {
		viewModel.url.observe(on: self) { [weak self] url in
			guard let url = url else { return }
			self?.webView.load(URLRequest(url: url))
		}
		viewModel.isLoading.observe(on: self) { isLoading in
			isLoading ? ProgressHUD.show() : ProgressHUD.dismiss()
		}
	}
}

// MARK: - WKNavigationDelegate

extension WebViewController {
	func webView(_ webView: WKWebView, didCommit navigation: WKNavigation) {
		viewModel.didUserDo(request: .didStartToLoad)
	}
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
		viewModel.didUserDo(request: .didFinishLoading)
	}
}

// MARK: - UI
private extension WebViewController {
	func applyStyle() {
		view.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
		[
			navBarView,
			webView
		].forEach { view.addSubview($0) }
		navBarView.makeConstraints { make in
			[
				make.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
				make.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
				make.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
				make.heightAnchor.constraint(equalToConstant: Appearance.navBarViewHeight)
			]
		}
		webView.makeEqualToSuperviewToSafeArea(
			insets: .init(top: Appearance.navBarViewHeight)
		)
	}
}

// MARK: - UI make
private extension WebViewController {
	func makeWebView() -> WKWebView {
		let webView = WKWebView()
		webView.backgroundColor = .clear
		webView.navigationDelegate = self
		webView.allowsBackForwardNavigationGestures = true

		webView.navigationDelegate = self

		// избегаю эффекта резинки - не нравится в темной теме белый фон
		webView.scrollView.bounces = false
		// но на нижней границе только так
		webView.scrollView.contentInset = Appearance.scrollViewContentInset

		return webView
	}
}

private extension WebViewController {
	enum Appearance {
		static let navBarViewHeight = 42.0
		static let scrollViewContentInset: UIEdgeInsets = .init(
			top: .zero, left: .zero, bottom: 1, right: .zero
		)
	}
}
