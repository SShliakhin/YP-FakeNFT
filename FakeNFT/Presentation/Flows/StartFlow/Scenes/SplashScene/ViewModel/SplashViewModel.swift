import Foundation

enum SplashEvents {
	case loadData
	case showErrorAlert(String, withRetry: Bool)
}
enum SplashRequest {
	case retryAction
}

protocol SplashViewModelInput: AnyObject {
	var didSendEventClosuer: ((SplashEvents) -> Void)? { get set }

	func viewIsReady()
	func didUserDo(request: SplashRequest)
}

protocol SplashViewModelOutput: AnyObject {
	var isLoading: Observable<Bool> { get }
}

typealias SplashViewModel = (
	SplashViewModelInput &
	SplashViewModelOutput
)

final class DefaultSplashViewModel: SplashViewModel {
	struct Dependencies {
		let networkMonitor: NetworkMonitor
		let getProfile: GetProfileUseCase
		let getOrder: GetOrderUseCase
		let getCollections: GetCollectionsUseCase
		let getAuthors: GetAuthorsUseCase
		let getNfts: GetNftsUseCase
		let profileRepository: ProfileRepository
		let likesIDsRepository: NftsIDsRepository
		let myNftsIDsRepository: NftsIDsRepository
		let orderIDsRepository: NftsIDsRepository
		let collectionsRepository: CollectionsRepository
		let authorsRepository: AuthorsRepository
	}
	private let dependencies: Dependencies
	private var retryAction: (() -> Void)?
	private var errors: [String] = []

	// MARK: - INPUT
	var didSendEventClosuer: ((SplashEvents) -> Void)?

	// MARK: - OUTPUT
	var isLoading: Observable<Bool> = Observable(false)

	// MARK: - Inits

	init(dep: Dependencies) {
		dependencies = dep
	}
}

// MARK: - INPUT
extension DefaultSplashViewModel {
	func viewIsReady() {
		fetchData()
	}
	func didUserDo(request: SplashRequest) {
		switch request {
		case .retryAction:
			retryAction?()
		}
	}
}

private extension DefaultSplashViewModel {
	func showLoadingError(message: String, completion: (() -> Void)? = nil) {
		retryAction = completion
		isLoading.value = false
		let withRetry = completion != nil ? true : false

		didSendEventClosuer?(.showErrorAlert(message, withRetry: withRetry))
	}

	func fetchData() {
		isLoading.value = true

		if !dependencies.networkMonitor.isConnected {
			showLoadingError(message: FakeNFTError.notConnectedToInternet.description) {
				self.fetchData()
			}
			return
		}

		errors = []
		beginFetching()
	}

	func beginFetching() {
		let group = DispatchGroup()

		fetchCollections(group: group)
		fetchProfile(group: group)
		fetchOrder(group: group)

		group.notify(queue: .main) {
			if !self.errors.isEmpty {
				let message = self.errors.joined(separator: "\n")
				self.showLoadingError(message: message) {
					self.fetchData()
				}
			} else {
				self.finishFetching()
			}
		}
	}

	func finishFetching() {
		let group = DispatchGroup()

		let idsAuthors = dependencies.collectionsRepository.items.map { $0.authorID }
		fetchAuthors(group: group, ids: idsAuthors)

		let idsNfts = Array(
			Set(
				dependencies.myNftsIDsRepository.items.value +
				dependencies.likesIDsRepository.items.value +
				dependencies.orderIDsRepository.items.value
			)
		)
		fetchNfts(group: group, ids: idsNfts)

		group.notify(queue: .main) {
			if !self.errors.isEmpty {
				let message = self.errors.joined(separator: "\n")
				self.showLoadingError(message: message) {
					self.fetchData()
				}
			} else {
				self.didSendEventClosuer?(.loadData)
				self.isLoading.value = false
			}
		}
	}

	func fetchAuthors(group: DispatchGroup, ids: [String]) {
		group.enter()
		dependencies.getAuthors.invoke(authorIDs: ids) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let authors):
				self.dependencies.authorsRepository.putItems(items: authors)
			case .failure(let error):
				self.errors.append(error.description)
			}
			group.leave()
		}
	}

	func fetchNfts(group: DispatchGroup, ids: [String]) {
		group.enter()
		dependencies.getNfts.invoke(nftIDs: ids) { [weak self] result in
			guard let self = self else { return }

			if case .failure(let error) = result {
				self.errors.append(error.description)
			}
			group.leave()
		}
	}

	func fetchCollections(group: DispatchGroup) {
		group.enter()
		dependencies.getCollections.invoke { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let collections):
				self.dependencies.collectionsRepository.putItems(items: collections)
			case .failure(let error):
				self.errors.append(error.description)
			}
			group.leave()
		}
	}

	func fetchProfile(group: DispatchGroup) {
		group.enter()
		dependencies.getProfile.invoke { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let profile):
				self.dependencies.profileRepository.profile.value = ProfileBody(
					name: profile.name,
					avatar: profile.avatar,
					description: profile.description,
					website: profile.website
				)
				self.dependencies.likesIDsRepository.putItems(nftIDs: profile.likes)
				self.dependencies.myNftsIDsRepository.putItems(nftIDs: profile.nfts)
			case .failure(let error):
				self.errors.append(error.description)
			}
			group.leave()
		}
	}

	func fetchOrder(group: DispatchGroup) {
		group.enter()
		dependencies.getOrder.invoke { [weak self] result in
			switch result {
			case .success(let order):
				self?.dependencies.orderIDsRepository.putItems(nftIDs: order.nfts)
			case .failure(let error):
				self?.errors.append(error.description)
			}
			group.leave()
		}
	}
}
