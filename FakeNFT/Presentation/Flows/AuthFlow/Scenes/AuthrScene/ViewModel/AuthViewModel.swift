enum AuthEvents {
	case close
}

enum AuthRequest {
	case didTapActionButton
}

protocol AuthViewModelInput: AnyObject {
	var didSendEventClosure: ((AuthEvents) -> Void)? { get set }

	func viewIsReady()
	func didUserDo(request: AuthRequest)
}

protocol AuthViewModelOutput: AnyObject {
	var titleScreen: String { get }
}

typealias AuthViewModel = (
	AuthViewModelInput &
	AuthViewModelOutput
)

final class DefaultAuthViewModel: AuthViewModel {
	// MARK: - INPUT
	var didSendEventClosure: ((AuthEvents) -> Void)?

	// MARK: - OUTPUT
	lazy var titleScreen: String = {
		String(describing: type(of: self))
	}()
}

// MARK: - INPUT. View event methods

extension DefaultAuthViewModel {
	func viewIsReady() {}

	func didUserDo(request: AuthRequest) {
		switch request {
		case .didTapActionButton:
			didSendEventClosure?(.close)
		}
	}
}
