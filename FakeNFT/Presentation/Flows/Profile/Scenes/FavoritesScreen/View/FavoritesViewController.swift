import UIKit
import ProgressHUD

final class FavoritesViewController: UIViewController {
	private let viewModel: FavoritesViewModel

	// MARK: - UI Elements
	private lazy var navBarView = NavBarView()
	private lazy var collectionView: UICollectionView = makeCollectionView()
	private lazy var emptyLabel: UILabel = LabelFactory.makeLabel(
		font: Theme.font(style: .headline),
		text: viewModel.emptyVCMessage
	)

	// MARK: - Inits

	init(viewModel: FavoritesViewModel) {
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
		collectionView.setContentOffset(CGPoint(x: .zero, y: -collectionView.contentInset.top), animated: false)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		showNavTabBars(animated)
	}
}

// MARK: - Bind

private extension FavoritesViewController {
	func bind(to viewModel: FavoritesViewModel) {
		viewModel.items.observe(on: self) { [weak self] _ in
			self?.updateItems()
		}
		viewModel.isLoading.observe(on: self) { isLoading in
			isLoading ? ProgressHUD.show() : ProgressHUD.dismiss()
		}
	}

	func updateItems() {
		collectionView.reloadData()
		checkAppearance()
	}

	func checkAppearance() {
		emptyLabel.isHidden = !viewModel.isEmpty
		navBarView.update(with: NavBarInputData(
			title: viewModel.isEmpty ? "" : viewModel.titleVC,
			isGoBackButtonHidden: false,
			isSortButtonHidden: true,
			onTapGoBackButton: { [weak self] in self?.viewModel.didUserDo(request: .goBack) },
			onTapSortButton: nil
		))
	}
}

// MARK: - UICollectionViewDataSource

extension FavoritesViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		viewModel.numberOfItems
	}

	func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		let model = viewModel.cellModelAtIndex(indexPath.row)
		return collectionView.dequeueReusableCell(withModel: model, for: indexPath)
	}
}

// MARK: - UI
private extension FavoritesViewController {
	func applyStyle() {
		view.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
		[
			navBarView,
			collectionView,
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
		collectionView.makeEqualToSuperviewToSafeArea(insets: Appearance.collectionViewInsets)
		emptyLabel.makeEqualToSuperviewCenterToSafeArea()
	}
}

// MARK: - UI make
private extension FavoritesViewController {
	func makeCollectionView() -> UICollectionView {
		let layout = createLayout()

		let collectionView = UICollectionView(
			frame: .zero,
			collectionViewLayout: layout
		)

		collectionView.register(models: viewModel.cellModels)
		collectionView.dataSource = self

		collectionView.backgroundColor = .clear

		return collectionView
	}
}

// MARK: - CompositionalLayout
private extension FavoritesViewController {
	func createLayout() -> UICollectionViewCompositionalLayout {
		UICollectionViewCompositionalLayout { [weak self] _, _ in
			self?.createListLayout()
		}
	}

	func createListLayout() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .fractionalHeight(1.0)
		)
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .absolute(Appearance.cellHeight)
		)
		let group = NSCollectionLayoutGroup.horizontal(
			layoutSize: groupSize,
			subitem: item,
			count: 2
		)
		group.interItemSpacing = .fixed(Appearance.groupInterItemSpacing)

		let section = createLayoutSection(
			group: group,
			behavior: .none,
			interGroupSpacing: Appearance.sectionInterGroupSpacing,
			supplementaryItem: [],
			contentInsets: Appearance.sectionContentInsets
		)

		return section
	}

	func createLayoutSection(
		group: NSCollectionLayoutGroup,
		behavior: UICollectionLayoutSectionOrthogonalScrollingBehavior,
		interGroupSpacing: CGFloat,
		supplementaryItem: [NSCollectionLayoutBoundarySupplementaryItem],
		contentInsets: NSDirectionalEdgeInsets
	) -> NSCollectionLayoutSection {
		let section = NSCollectionLayoutSection(group: group)
		section.orthogonalScrollingBehavior = behavior
		section.interGroupSpacing = interGroupSpacing
		section.boundarySupplementaryItems = supplementaryItem
		section.contentInsets = contentInsets

		return section
	}
}

private extension FavoritesViewController {
	enum Appearance {
		static let navBarViewHeight = 42.0
		static let collectionViewInsets: UIEdgeInsets = .init(top: 62)
		static let cellHeight = 80.0
		static let groupInterItemSpacing = 7.0
		static let sectionInterGroupSpacing = 20.0
		static let sectionContentInsets: NSDirectionalEdgeInsets = .init(
			top: .zero, leading: 16, bottom: .zero, trailing: 16
		)
	}
}
