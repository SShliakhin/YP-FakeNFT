import UIKit
import ProgressHUD

final class CollectionViewController: UIViewController {

	private var viewModel: CollectionViewModel

	// MARK: - UI Elements
	private lazy var goBackButton: UIButton = makeGoBackButton()
	private lazy var collectionView: UICollectionView = makeCollectionView()

	// MARK: - Inits

	init(viewModel: CollectionViewModel) {
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
		ProgressHUD.show()
		viewModel.viewIsReady()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		hideNavTabBars(animated)
		collectionView.setContentOffset(CGPoint(x: .zero, y: -collectionView.contentInset.top), animated: false)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		showNavTabBars(animated)
	}
}

// MARK: - Bind

private extension CollectionViewController {
	func bind(to viewModel: CollectionViewModel) {
		viewModel.dataSource.observe(on: self) { [weak self] _ in
			self?.updateSections()
		}
		viewModel.likes.observe(on: self) { [weak self] _ in
			self?.updateItems()
		}
		viewModel.order.observe(on: self) { [weak self] _ in
			self?.updateItems()
		}
	}

	func updateSections() {
		collectionView.reloadData()
		ProgressHUD.dismiss()
	}
	func updateItems() {
		guard collectionView.numberOfSections > 0 else { return }
		collectionView.reloadSections([1])
		ProgressHUD.dismiss()
	}
}

// MARK: - UICollectionViewDataSource

extension CollectionViewController: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		viewModel.numberOfSection
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		viewModel.numberOfItemInSection(section)
	}

	func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		let model = viewModel.cellModelInSectionAtIndex(section: indexPath.section, index: indexPath.row)
		return collectionView.dequeueReusableCell(withModel: model, for: indexPath)
	}
}

// MARK: - UI
private extension CollectionViewController {
	func applyStyle() {
		view.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
		[
			collectionView,
			goBackButton
		].forEach { view.addSubview($0) }

		collectionView.makeEqualToSuperview()
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
private extension CollectionViewController {
	func makeGoBackButton() -> UIButton {
		let button = UIButton(type: .custom)
		button.setImage(Theme.image(kind: .goBack), for: .normal)
		button.tintColor = Theme.color(usage: .black)
		button.event = { [weak self] in self?.viewModel.didUserDo(request: .goBack) }

		return button
	}

	func makeCollectionView() -> UICollectionView {
		let layout = createLayout()

		let collectionView = UICollectionView(
			frame: .zero,
			collectionViewLayout: layout
		)

		collectionView.register(models: viewModel.cellModels)
		collectionView.dataSource = self

		collectionView.backgroundColor = .clear

		collectionView.contentInsetAdjustmentBehavior = .never

		return collectionView
	}
}

// MARK: - CompositionalLayout
private extension CollectionViewController {
	func createLayout() -> UICollectionViewCompositionalLayout {
		UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
			guard let self = self else { return nil }
			switch sectionIndex {
			case .zero:
				return self.createHeaderLayout()
			default:
				return self.createListLayout()
			}
		}
	}

	func createLayoutSection(
		group: NSCollectionLayoutGroup,
		behavior: UICollectionLayoutSectionOrthogonalScrollingBehavior,
		interGroupSpacing: CGFloat,
		supplementaryItem: [NSCollectionLayoutBoundarySupplementaryItem]
	) -> NSCollectionLayoutSection {
		let section = NSCollectionLayoutSection(group: group)
		section.orthogonalScrollingBehavior = behavior
		section.interGroupSpacing = interGroupSpacing
		section.boundarySupplementaryItems = supplementaryItem

		return section
	}

	func createHeaderLayout() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .estimated(1.0)
		)
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .estimated(1.0)
		)
		let group = NSCollectionLayoutGroup.horizontal(
			layoutSize: groupSize,
			subitem: item,
			count: 1 // кол-во элементов в группе
		)

		let section = createLayoutSection(
			group: group, // минимально let section = NSCollectionLayoutSection(group: group)
			behavior: .none, // важно для скроллинга
			interGroupSpacing: .zero, // по вертикали между группами
			supplementaryItem: []
		)
		// отступы для секции
		section.contentInsets = NSDirectionalEdgeInsets(
			top: .zero,
			leading: .zero,
			bottom: Theme.spacing(usage: .standard3),
			trailing: .zero
		)

		return section
	}

	func createListLayout() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .fractionalHeight(1.0)
		)
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .absolute(192)
		)
		let group = NSCollectionLayoutGroup.horizontal(
			layoutSize: groupSize,
			subitem: item,
			count: 3 // кол-во элементов в группе
		)
		group.interItemSpacing = .fixed(Theme.spacing(usage: .standard))

		let section = createLayoutSection(
			group: group, // минимально let section = NSCollectionLayoutSection(group: group)
			behavior: .none, // важно для скроллинга
			interGroupSpacing: Theme.spacing(usage: .standard), // по вертикали между группами
			supplementaryItem: []
		)
		// отступы для секции
		section.contentInsets = NSDirectionalEdgeInsets(
			top: .zero,
			leading: Theme.spacing(usage: .standard2),
			bottom: .zero,
			trailing: Theme.spacing(usage: .standard2)
		)

		return section
	}
}
