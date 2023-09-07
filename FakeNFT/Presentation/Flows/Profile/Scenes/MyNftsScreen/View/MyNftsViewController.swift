import UIKit
import ProgressHUD
import StoreKit

final class MyNftsViewController: UIViewController {
	private let viewModel: MyNftsViewModel

	// MARK: - UI Elements
	private lazy var navBarView = NavBarView()
	private lazy var tableView: UITableView = makeTableView()
	private lazy var emptyLabel: UILabel = LabelFactory.makeLabel(
		font: Theme.font(style: .headline)
	)
	private lazy var searchController: UISearchController = makeSearchController()

	// MARK: - Inits

	init(viewModel: MyNftsViewModel) {
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
		tableView.setContentOffset(CGPoint(x: .zero, y: -tableView.contentInset.top), animated: false)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		showNavTabBars(animated)
	}
}

// MARK: - Bind

private extension MyNftsViewController {
	func bind(to viewModel: MyNftsViewModel) {
		viewModel.items.observe(on: self) { [weak self] _ in
			self?.updateItems()
		}
		viewModel.authors.observe(on: self) { [weak self] _ in
			self?.updateItems()
		}
		viewModel.likes.observe(on: self) { [weak self] _ in
			self?.updateItems()
			self?.askForReview()
		}
		viewModel.isLoading.observe(on: self) { isLoading in
			isLoading ? ProgressHUD.show() : ProgressHUD.dismiss()
		}
	}

	func updateItems() {
		tableView.reloadData()
		checkAppearance()
	}

	func askForReview() {
		if viewModel.isTimeToRequestReview {
			SKStoreReviewController.requestReview()
		}
	}

	func checkAppearance() {
		emptyLabel.isHidden = !viewModel.isEmpty
		emptyLabel.text = viewModel.emptyVCMessage

		navBarView.update(with: NavBarInputData(
			title: viewModel.isEmpty ? "" : viewModel.titleVC,
			isGoBackButtonHidden: false,
			isSortButtonHidden: viewModel.isEmpty,
			onTapGoBackButton: { [weak self] in self?.viewModel.didUserDo(request: .goBack) },
			onTapSortButton: { [weak self] in self?.viewModel.didUserDo(request: .selectSort) }
		))
	}
}

// MARK: - UITableViewDataSource

extension MyNftsViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.numberOfItems
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let model = viewModel.cellModelAtIndex(indexPath.row)
		return tableView.dequeueReusableCell(withModel: model, for: indexPath)
	}
}

// MARK: - UISearchResultsUpdating

extension MyNftsViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		guard let query = searchController.searchBar.text else { return }
		viewModel.didUserDo(request: .filterItemsBy(query))
	}
}

// MARK: - UI
private extension MyNftsViewController {
	func applyStyle() {
		view.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
		[
			navBarView,
			tableView,
			emptyLabel
		].forEach { view.addSubview($0) }

		navBarView.makeConstraints { make in
			[
				make.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
				make.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
				make.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
				make.heightAnchor.constraint(equalToConstant: Appearance.navBarViewHeight)
			]
		}
		tableView.makeEqualToSuperviewToSafeArea(insets: Appearance.tableViewInsets)
		emptyLabel.makeEqualToSuperviewCenterToSafeArea()
	}
}

// MARK: - UI make
private extension MyNftsViewController {
	func makeTableView() -> UITableView {
		let tableView = UITableView()

		tableView.register(models: viewModel.cellModels)
		tableView.rowHeight = Appearance.cellHeight

		tableView.dataSource = self

		tableView.tableHeaderView = searchController.searchBar
		tableView.bounces = false // из-за поиска испортился задний фон при пружине

		tableView.tableFooterView = UIView()
		tableView.separatorStyle = .none

		tableView.backgroundColor = .clear

		return tableView
	}

	func makeSearchController() -> UISearchController {
		let search = UISearchController(searchResultsController: nil)
		search.searchResultsUpdater = self
		search.obscuresBackgroundDuringPresentation = false
		search.hidesNavigationBarDuringPresentation = false
		definesPresentationContext = true

		// решаем проблему с обрамлением и прозрачностью
		search.searchBar.backgroundImage = UIImage()
		search.searchBar.backgroundColor = Theme.color(usage: .white)

		search.searchBar.searchTextField.font = Theme.font(style: .body)
		search.searchBar.searchTextField.textColor = Theme.color(usage: .main)
		search.searchBar.searchTextField.placeholder = viewModel.placeholderSearchByTitle

		return search
	}
}

private extension MyNftsViewController {
	enum Appearance {
		static let navBarViewHeight = 42.0
		static let tableViewInsets: UIEdgeInsets = .init(top: 62)
		static let cellHeight = 140.0
	}
}
