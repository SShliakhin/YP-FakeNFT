import Foundation

enum SplashEvents {
	case loadData
	case showErrorAlert(String, Bool)
}
enum SplashRequest {
	case retryAction
}

protocol SplashViewModelInput: AnyObject {
	var didSendEventClouser: ((SplashEvents) -> Void)? { get set }

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
		let likesRepository: NftsIDsRepository
		let myNftsRepository: NftsIDsRepository
	}
	private let dependencies: Dependencies
	private var retryAction: (() -> Void)?

	// MARK: - INPUT
	var didSendEventClouser: ((SplashEvents) -> Void)?

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
			self?.fetchProfile()
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
	func fetchProfile() {
		isLoading.value = true

		dependencies.getProfile.invoke { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let profile):
				self.dependencies.likesRepository.putItems(nftIDs: profile.likes)
				self.dependencies.myNftsRepository.putItems(nftIDs: profile.nfts)
			case .failure(let error):
				self.retryAction = { self.viewIsReady() }
				self.didSendEventClouser?(.showErrorAlert(error.description, true))
			}

			self.isLoading.value = false
			self.didSendEventClouser?(.loadData)
		}
	}
}
