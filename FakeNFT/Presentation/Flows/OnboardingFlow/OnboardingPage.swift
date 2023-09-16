import UIKit

enum OnboardingPage: Int {
	case explore
	case collect
	case compete

	var titleValue: String {
		switch self {
		case .explore:
			return L10n.Onboarding.titleExplore
		case .collect:
			return L10n.Onboarding.titleCollect
		case .compete:
			return L10n.Onboarding.titleCompete
		}
	}

	var textValue: String {
		switch self {
		case .explore:
			return L10n.Onboarding.textExplore
		case .collect:
			return L10n.Onboarding.textCollect
		case .compete:
			return L10n.Onboarding.textCompete
		}
	}

	var imageValue: UIImage {
		switch self {
		case .explore:
			return Theme.image(kind: .onboardingPage1)
		case .collect:
			return Theme.image(kind: .onboardingPage2)
		case .compete:
			return Theme.image(kind: .onboardingPage3)
		}
	}

	static let fullOnboarding: [OnboardingPage] = [.explore, .collect, .compete]

	var pageOrderNumber: Int? {
		OnboardingPage.fullOnboarding.firstIndex { $0 == self }
	}

	var shouldShowCloseButton: Bool {
		guard
			let pageOrderNumber = pageOrderNumber,
			pageOrderNumber < OnboardingPage.fullOnboarding.count - 1
		else { return false }
		return true
	}

	var shouldShowNextButton: Bool {
		guard
			let pageOrderNumber = pageOrderNumber,
			pageOrderNumber == OnboardingPage.fullOnboarding.count - 1
		else { return false }
		return true
	}
}
