import UIKit
import ProgressHUD

final class CatalogViewController: UIViewController {
	private let viewModel: CatalogViewModel

	// MARK: - UI Elements
	private lazy var sortCollectionsBarButtonItem: UIBarButtonItem = makeSortCollectionsBarButtonItem()
	private lazy var tableView: UITableView = makeTableView()

	// MARK: - Inits

	init(viewModel: CatalogViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		setup()
		applyStyle()
		setConstraints()

		bind(to: viewModel)
		viewModel.viewIsReady()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		tableView.setContentOffset(CGPoint(x: .zero, y: -tableView.contentInset.top), animated: false)
	}
}

// MARK: - Bind

private extension CatalogViewController {
	func bind(to viewModel: CatalogViewModel) {
		viewModel.items.observe(on: self) { [weak self] _ in
			self?.updateItems()
		}
		viewModel.isLoading.observe(on: self) { isLoading in
			isLoading ? ProgressHUD.show() : ProgressHUD.dismiss()
		}
	}

	func updateItems() {
		tableView.reloadData()
	}
}

// MARK: - Actions
private extension CatalogViewController {
	@objc func didTapSortCollectionsButton(_ sender: Any) {
		viewModel.didUserDo(request: .selectSort)
	}
}

// MARK: UITableViewDataSource

extension CatalogViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.numberOfItems
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let model = viewModel.cellModelAtIndex(indexPath.row)
		return tableView.dequeueReusableCell(withModel: model, for: indexPath)
	}
}

// MARK: UITableViewDelegate

extension CatalogViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		viewModel.didUserDo(request: .selectItemAtIndex(indexPath.row))
	}
}

// MARK: - UI
private extension CatalogViewController {
	func setup() {
		navigationItem.rightBarButtonItem = sortCollectionsBarButtonItem
	}
	func applyStyle() {
		view.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
		[
			tableView
		].forEach { view.addSubview($0) }

		tableView.makeEqualToSuperviewToSafeArea(
			insets: .init(top: Theme.spacing(usage: .constant20))
		)
	}
}

// MARK: - UI make
private extension CatalogViewController {
	func makeSortCollectionsBarButtonItem() -> UIBarButtonItem {
		let button = UIBarButtonItem(
			image: Theme.image(kind: .sortIcon),
			style: .plain,
			target: self,
			action: #selector(didTapSortCollectionsButton)
		)
		button.tintColor = Theme.color(usage: .black)

		return button
	}
	func makeTableView() -> UITableView {
		let tableView = UITableView()

		tableView.register(models: viewModel.cellModels)
		tableView.rowHeight = 187.0

		tableView.dataSource = self
		tableView.delegate = self

		tableView.tableFooterView = UIView()
		tableView.separatorStyle = .none

		tableView.backgroundColor = .clear

		return tableView
	}
}
