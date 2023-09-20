enum OnboardingEvents {
	case close
}

enum OnboardingRequest {
	case didTapActionButton
	case showPage(Int)
}

protocol OnboardingViewModelInput: AnyObject {
	var didSendEventClosure: ((OnboardingEvents) -> Void)? { get set }

	func viewIsReady()
	func didUserDo(request: OnboardingRequest)
}

protocol OnboardingViewModelOutput: AnyObject, OnboardingPageControl {
	var renderMe: Observable<Bool> { get }

	var pagesData: [OnboardingPageData] { get }
	var pageNumber: Int { get }
}

typealias OnboardingViewModel = (
	OnboardingViewModelInput &
	OnboardingViewModelOutput
)

final class DefaultOnboardingViewModel: OnboardingViewModel {
	struct Dependencies {
		let onboardingData: [OnboardingPage]
	}
	private let dependencies: Dependencies
	private var currentPage: OnboardingPage?

	// MARK: - INPUT
	var didSendEventClosure: ((OnboardingEvents) -> Void)?

	// MARK: - OUTPUT
	var renderMe: Observable<Bool> = Observable(false)

	var pagesData: [OnboardingPageData] { dependencies.onboardingData }

	var pageOrderNumber: Int?
	var pageNumber: Int {
		guard
			let currentPage = currentPage,
			let num = currentPage.pageOrderNumber
		else { return .zero }
		return num
	}
	var numberOfPages: Int {
		guard let currentPage = currentPage else { return .zero }
		return currentPage.numberOfPages
	}
	var completionButtonTitle: String {
		guard let currentPage = currentPage else { return "" }
		return currentPage.completionButtonTitle
	}
	var shouldShowCloseButton: Bool {
		guard let currentPage = currentPage else { return false }
		return currentPage.shouldShowCloseButton
	}
	var shouldShowCompletionButton: Bool {
		guard let currentPage = currentPage else { return false }
		return currentPage.shouldShowCompletionButton
	}

	init(dep: Dependencies) {
		dependencies = dep
		currentPage = dep.onboardingData.first
	}
}

// MARK: - INPUT. View event methods

extension DefaultOnboardingViewModel {
	func viewIsReady() {
		renderMe.value = true
	}

	func didUserDo(request: OnboardingRequest) {
		switch request {
		case .didTapActionButton:
			didSendEventClosure?(.close)
		case .showPage(let index):
			let page = dependencies.onboardingData[index]
			if page != currentPage {
				currentPage = page
				renderMe.value = true
			}
		}
	}
}
