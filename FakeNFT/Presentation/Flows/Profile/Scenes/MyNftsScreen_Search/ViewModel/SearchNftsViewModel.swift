import Foundation

final class SearchNftsViewModel: NSObject, MyNftsViewModel {
	struct Dependencies {
		let searchNftsByName: SearchNftsByNameUseCase
		let getSetSortOption: SortMyNtfsOption
		let putLike: PutLikeByIDUseCase
		let getAuthors: GetAuthorsUseCase
		let likesIDsRepository: NftsIDsRepository
	}
	private let dependencies: Dependencies
	private var retryAction: (() -> Void)?
	private var isSearchActive = false
	private var likesForReview: Int

	// MARK: - INPUT
	var didSendEventClosure: ((MyNftsEvents) -> Void)?

	// MARK: - OUTPUT
	var items: Observable<[Nft]> = Observable([])
	var authors: Observable<[Author]> = Observable([])

	var isLoading: Observable<Bool> = Observable(false)
	var isTimeToCheckLikes: Observable<Bool> = Observable(false)
	var isTimeToRequestReview: Bool {
		let currentLikes = dependencies.likesIDsRepository.numberOfItems
		if currentLikes >= likesForReview {
			likesForReview += Appearance.incrementToRequestReview
			return true
		}
		return false
	}

	var numberOfItems: Int { items.value.count }
	var isEmpty: Bool { items.value.isEmpty }
	var cellModels: [ICellViewAnyModel.Type] = [MyNftsItemCellModel.self]

	var emptyVCMessage: String {
		return isSearchActive ? L10n.SearchBar.noSearchResult : ""
	}

	var placeholderSearchByTitle: String = L10n.SearchBar.SearchByTitle
	var navBarData: NavBarInputData { getNavBarData() }

	// MARK: - Inits

	init(dep: Dependencies) {
		dependencies = dep
		likesForReview = dep.likesIDsRepository.numberOfItems + Appearance.incrementToRequestReview

		super.init()
		bind(to: dep.likesIDsRepository)
	}
}

// MARK: - Bind

private extension SearchNftsViewModel {
	func bind(to repository: NftsIDsRepository) {
		repository.items.observe(on: self) { [weak self] _ in
			self?.didUserDo(request: .like)
		}
	}
}

// MARK: - OUTPUT

extension SearchNftsViewModel {
	func cellModelAtIndex(_ index: Int) -> ICellViewAnyModel {
		let nft = items.value[index]
		let isFavorite = dependencies.likesIDsRepository.hasItemByID(nft.id)
		let author = authors.value.first { $0.id == nft.authorID }?.name ?? ""
		let price = Theme.getPriceStringFromDouble(nft.price)

		return MyNftsItemCellModel(
			avatarImageURL: nft.cover,
			isFavorite: isFavorite,
			title: nft.name,
			rating: nft.rating,
			author: author,
			price: price,
			onTapFavorite: { [weak self] in self?.likeItemWithID(nft.id) }
		)
	}
}

// MARK: - INPUT. View event methods

extension SearchNftsViewModel {
	func viewIsReady() {}
	func didUserDo(request: MyNftsRequest) {
		switch request {
		case .selectSort:
			guard items.value.count > 1 else { return }
			didSendEventClosure?(.showSortAlert)
		case .selectSortBy(let sortBy):
			dependencies.getSetSortOption.setOption(sortBy)
			sortItems()
		case .retryAction:
			retryAction?()
		case .goBack:
			didSendEventClosure?(.close)
		case .filterItemsBy(let term):
			// debounce
			NSObject.cancelPreviousPerformRequests(withTarget: self)
			perform(#selector(searchNftsWith(_:)), with: term, afterDelay: TimeInterval(1.0))
		case .list:
			break
		case .like:
			isTimeToCheckLikes.value = true
		}
	}
}

private extension SearchNftsViewModel {
	@objc func searchNftsWith(_ text: String) {
		let text = text
			.trimmingCharacters(in: .whitespaces)
			.lowercased()
		if text.isEmpty {
			isSearchActive = false
			items.value = []
			return
		}

		isSearchActive = true
		isLoading.value = true

		dependencies.searchNftsByName.invoke(
			searchText: text
		) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let nfts):
				self.items.value = nfts
				self.fetchAuthors()
			case .failure(let error):
				self.items.value = []
				self.retryAction = nil
				self.didSendEventClosure?(
					.showErrorAlert(error.description, withRetry: false)
				)
			}

			self.sortItems()
			self.isLoading.value = false
		}
	}

	func fetchAuthors() {
		isLoading.value = true

		let authorsID = Array(Set(items.value.map { $0.authorID }))
		dependencies.getAuthors.invoke(authorIDs: authorsID) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let authors):
				self.authors.value = authors
			case .failure(let error):
				self.retryAction = nil
				self.didSendEventClosure?(
					.showErrorAlert(error.description, withRetry: false)
				)
			}

			self.isLoading.value = false
		}
	}

	func likeItemWithID(_ nftID: String) {
		isLoading.value = true

		dependencies.putLike.invoke(nftID) { [weak self] result in
			guard let self = self else { return }
			if case .failure(let error) = result {
				self.retryAction = nil
				self.didSendEventClosure?(
					.showErrorAlert(error.description, withRetry: false)
				)
			}
			self.isLoading.value = false
		}
	}

	func sortItems() {
		guard numberOfItems > 1 else { return }

		let sortBy = dependencies.getSetSortOption.sortBy
		switch sortBy {
		case .name:
			items.value = items.value.sorted { $0.name < $1.name }
		case .price:
			items.value = items.value.sorted { $0.price > $1.price }
		case .rating:
			items.value = items.value.sorted { $0.rating > $1.rating }
		}
	}

	func getNavBarData() -> NavBarInputData {
		let title: String
		switch(isEmpty, isSearchActive) {
		case (true, true):
			title = ""
		case (false, _):
			title = String(format: L10n.Profile.titleVCSearchResult, numberOfItems)
		case (_, false):
			title = L10n.Profile.titleVCSearchInvite
		}

		return NavBarInputData(
			title: title,
			isGoBackButtonHidden: false,
			isSortButtonHidden: isEmpty,
			onTapGoBackButton: { [weak self] in
				self?.didUserDo(request: .goBack)
			},
			onTapSortButton: { [weak self] in
				self?.didUserDo(request: .selectSort)
			}
		)
	}
}

private extension SearchNftsViewModel {
	enum Appearance {
		static let incrementToRequestReview = 5
	}
}
