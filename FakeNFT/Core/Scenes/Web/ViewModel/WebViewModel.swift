import Foundation

enum WebEvents {
	case close
}

enum WebRequest {
	case goBack
	case didStartToLoad
	case didFinishLoading
}

protocol WebViewModelInput: AnyObject {
	var didSendEventClosure: ((WebEvents) -> Void)? { get set }

	func viewIsReady()
	func didUserDo(request: WebRequest)
}

protocol WebViewModelOutput: AnyObject {
	var url: Observable<URL?> { get }
	var isLoading: Observable<Bool> { get }
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
	var isLoading: Observable<Bool> = Observable(false)

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
			isLoading.value = false
			didSendEventClosure?(.close)
		case .didStartToLoad:
			isLoading.value = true
		case .didFinishLoading:
			isLoading.value = false
		}
	}
}
