import Foundation

enum WebCatalogEvents {
	case close
}

enum WebCatalogRequest {
	case goBack
}

protocol WebCatalogViewModelInput: AnyObject {
	var didSendEventClosure: ((WebCatalogEvents) -> Void)? { get set }

	func viewIsReady()
	func didUserDo(request: WebCatalogRequest)
}

protocol WebCatalogViewModelOutput: AnyObject {
	var url: Observable<URL?> { get }
}

typealias WebCatalogViewModel = (
	WebCatalogViewModelInput &
	WebCatalogViewModelOutput
)

final class DefaultWebCatalogViewModel: WebCatalogViewModel {
	struct Dependencies {
		let url: URL
	}
	private let dependencies: Dependencies

	// MARK: - INPUT
	var didSendEventClosure: ((WebCatalogEvents) -> Void)?

	// MARK: - OUTPUT
	var url: Observable<URL?> = Observable(nil)

	// MARK: - Inits

	init(dep: Dependencies) {
		dependencies = dep
	}
}

// MARK: - INPUT. View event methods

extension DefaultWebCatalogViewModel {
	func viewIsReady() {
		url.value = dependencies.url
	}

	func didUserDo(request: WebCatalogRequest) {
		switch request {
		case .goBack:
			didSendEventClosure?(.close)
		}
	}
}
