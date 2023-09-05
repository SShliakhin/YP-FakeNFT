enum OnboardingEvents {
	case close
}

enum OnboardingRequest {
	case didTapActionButton
}

protocol OnboardingViewModelInput: AnyObject {
	var didSendEventClosure: ((OnboardingEvents) -> Void)? { get set }

	func viewIsReady()
	func didUserDo(request: OnboardingRequest)
}

protocol OnboardingViewModelOutput: AnyObject {
	var titleScreen: String { get }
}

typealias OnboardingViewModel = (
	OnboardingViewModelInput &
	OnboardingViewModelOutput
)

final class DefaultOnboardingViewModel: OnboardingViewModel {

	// MARK: - INPUT
	var didSendEventClosure: ((OnboardingEvents) -> Void)?

	// MARK: - OUTPUT
	lazy var titleScreen: String = {
		String(describing: type(of: self))
	}()
}

// MARK: - INPUT. View event methods

extension DefaultOnboardingViewModel {
	func viewIsReady() {}

	func didUserDo(request: OnboardingRequest) {
		switch request {
		case .didTapActionButton:
			didSendEventClosure?(.close)
		}
	}
}
