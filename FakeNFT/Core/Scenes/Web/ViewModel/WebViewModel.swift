import Foundation

enum WebEvents {
	case close
}

enum WebRequest {
	case goBack
}

protocol WebViewModelInput: AnyObject {
	var didSendEventClosure: ((WebEvents) -> Void)? { get set }

	func viewIsReady()
	func didUserDo(request: WebRequest)
}

protocol WebViewModelOutput: AnyObject {
	var url: Observable<URL?> { get }
}

typealias WebViewModel = (
	WebViewModelInput &
	WebViewModelOutput
)

final class DefaultWebViewModel: WebViewModel {
	struct Dependencies {
		let url: URL
	}
	private let dependencies: Dependencies

	// MARK: - INPUT
	var didSendEventClosure: ((WebEvents) -> Void)?

	// MARK: - OUTPUT
	var url: Observable<URL?> = Observable(nil)

	// MARK: - Inits

	init(dep: Dependencies) {
		dependencies = dep
	}
}

// MARK: - INPUT. View event methods

extension DefaultWebViewModel {
	func viewIsReady() {
		url.value = dependencies.url
	}

	func didUserDo(request: WebRequest) {
		switch request {
		case .goBack:
			didSendEventClosure?(.close)
		}
	}
}
