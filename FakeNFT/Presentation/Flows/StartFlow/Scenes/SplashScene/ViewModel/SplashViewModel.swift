import Foundation

enum SplashEvents {
	case loadData
	case error(FakeNFTError)
}
enum SplashRequest {}

protocol SplashViewModelInput: AnyObject {
	var didSendEventClouser: ((SplashEvents) -> Void)? { get set }

	func viewIsReady()
	func didUserDo(request: SplashRequest)
}

protocol SplashViewModelOutput: AnyObject {}

typealias SplashViewModel = (
	SplashViewModelInput &
	SplashViewModelOutput
)

final class SplashViewModelImp: SplashViewModel {
	var didSendEventClouser: ((SplashEvents) -> Void)?

	func viewIsReady() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
			self?.didSendEventClouser?(.loadData)
		}
	}
	func didUserDo(request: SplashRequest) {}
}
