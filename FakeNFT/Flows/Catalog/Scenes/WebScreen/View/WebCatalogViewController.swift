//
//  WebCatalogViewController.swift
//  FakeNFT
import UIKit
import WebKit

final class WebCatalogViewController: UIViewController, WKNavigationDelegate {
	private let viewModel: WebCatalogViewModel

	// MARK: - UI Elements
	private lazy var goBackButton: UIButton = makeGoBackButton()
	private lazy var webView: WKWebView = makeWebView()

	// MARK: - Inits

	init(viewModel: WebCatalogViewModel) {
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

private extension WebCatalogViewController {
	func bind(to viewModel: WebCatalogViewModel) {
		viewModel.url.observe(on: self) { [weak self] url in
			guard let url = url else { return }
			self?.webView.load(URLRequest(url: url))
		}
	}
}

// MARK: - UI
private extension WebCatalogViewController {
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
private extension WebCatalogViewController {
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
		webView.scrollView.contentInset = UIEdgeInsets(
			top: .zero, left: .zero, bottom: 1, right: .zero
		)

		return webView
	}
}
