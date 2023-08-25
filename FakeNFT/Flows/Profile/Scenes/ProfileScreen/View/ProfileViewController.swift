import UIKit
import ProgressHUD

final class ProfileViewController: UIViewController {
	private let viewModel: ProfileViewModel
	private var hasViewIsReady = false

	// MARK: - UI Elements
	private lazy var editProfileBarButtonItem: UIBarButtonItem = makeEditProfileBarButtonItem()
	private var profileHeaderView = ProfileHeaderView()
	private lazy var tableView: UITableView = makeTableView()

	// MARK: - Inits

	init(viewModel: ProfileViewModel) {
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

		// временное решение: пока нет общего store, надо обновляться
		if !hasViewIsReady {
			hasViewIsReady = true
			return
		}

		viewModel.viewIsReady()
	}
}

// MARK: - Bind

private extension ProfileViewController {
	func bind(to viewModel: ProfileViewModel) {
		viewModel.items.observe(on: self) { [weak self] _ in
			self?.updateItems()
		}
		viewModel.profile.observe(on: self) { [weak self] profile in
			guard let profile = profile else { return }
			self?.profileHeaderView.update(with: profile)
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
private extension ProfileViewController {
	@objc func didTapEditProfileButton(_ sender: Any) {
		viewModel.didUserDo(request: .editProfile)
	}
}

// MARK: UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.numberOfItems
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let model = viewModel.cellModelAtIndex(indexPath.row)
		return tableView.dequeueReusableCell(withModel: model, for: indexPath)
	}
}

// MARK: UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		viewModel.didUserDo(request: .selectItemAtIndex(indexPath.row))
	}
}

// MARK: - UI
private extension ProfileViewController {
	func setup() {
		navigationItem.rightBarButtonItem = editProfileBarButtonItem
	}
	func applyStyle() {
		view.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
		let vStack = UIStackView(arrangedSubviews: [profileHeaderView, tableView])
		vStack.axis = .vertical

		view.addSubview(vStack)
		vStack.makeEqualToSuperviewToSafeArea()
	}
}

// MARK: - UI make
private extension ProfileViewController {
	func makeEditProfileBarButtonItem() -> UIBarButtonItem {
		let headline = UIImage.SymbolConfiguration(textStyle: .headline)
		let bold = UIImage.SymbolConfiguration(weight: .bold)
		let combined = headline.applying(bold)

		let button = UIBarButtonItem(
			image: Theme.image(kind: .editProfile).withConfiguration(combined),
			style: .plain,
			target: self,
			action: #selector(didTapEditProfileButton)
		)
		button.tintColor = Theme.color(usage: .black)

		return button
	}
	func makeTableView() -> UITableView {
		let tableView = UITableView()

		tableView.register(models: viewModel.cellModels)

		tableView.dataSource = self
		tableView.delegate = self

		tableView.tableFooterView = UIView()

		tableView.separatorStyle = .none
		tableView.rowHeight = Appearance.tableRowHeight

		tableView.bounces = false
		tableView.backgroundColor = .clear

		return tableView
	}
}

private extension ProfileViewController {
	enum Appearance {
		static let tableRowHeight = 54.0
	}
}
