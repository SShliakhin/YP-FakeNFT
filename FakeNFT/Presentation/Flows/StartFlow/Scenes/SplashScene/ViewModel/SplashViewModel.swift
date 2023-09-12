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
		let getProfile: GetProfileUseCase
		let getOrder: GetOrderUseCase
		let getCollections: GetCollectionsUseCase
		let getAuthors: GetAuthorsUseCase
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
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
			self?.fetchData()
		}
	}
	func didUserDo(request: SplashRequest) {
		switch request {
		case .retryAction:
			retryAction?()
		}
	}
}

private extension DefaultSplashViewModel {
	func fetchData() {
		isLoading.value = true

		errors = []
		let group = DispatchGroup()

		fetchCollections(group: group)
		fetchProfile(group: group)
		fetchOrder(group: group)

		group.notify(queue: .main) {
			if !self.errors.isEmpty {
				self.retryAction = { self.viewIsReady() }
				let message = self.errors.joined(separator: "\n")
				self.didSendEventClosuer?(.showErrorAlert(message, withRetry: true))
			} else {
				self.didSendEventClosuer?(.loadData)
			}

			self.isLoading.value = false
		}
	}

	func fetchCollections(group: DispatchGroup) {
		group.enter()
		dependencies.getCollections.invoke { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let collections):
				self.dependencies.collectionsRepository.putItems(items: collections)

				// TODO: - есть лучший вариант?
				let ids = collections.map { $0.authorID }
				self.fetchAuthors(group: group, ids: ids)

			case .failure(let error):
				self.errors.append(error.description)
			}
			group.leave()
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

	func fetchProfile(group: DispatchGroup) {
		group.enter()
		dependencies.getProfile.invoke { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let profile):
				self.dependencies.profileRepository.profile.value = ProfileUpdate(
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
