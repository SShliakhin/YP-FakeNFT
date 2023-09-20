import UIKit

protocol OnboardingPageData {
	var titleValue: String { get }
	var textValue: String { get }
	var imageAssetValue: Theme.ImageAsset { get }
}

protocol OnboardingPageControl {
	var completionButtonTitle: String { get }
	var numberOfPages: Int { get }
	var pageOrderNumber: Int? { get }
	var shouldShowCloseButton: Bool { get }
	var shouldShowCompletionButton: Bool { get }
}

enum OnboardingPage: OnboardingPageData, OnboardingPageControl {
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

	var imageAssetValue: Theme.ImageAsset {
		switch self {
		case .explore:
			return .onboardingPage1
		case .collect:
			return .onboardingPage2
		case .compete:
			return .onboardingPage3
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

	var shouldShowCompletionButton: Bool {
		guard
			let pageOrderNumber = pageOrderNumber,
			pageOrderNumber == OnboardingPage.fullOnboarding.count - 1
		else { return false }
		return true
	}

	var completionButtonTitle: String {
		L10n.Onboarding.completionButtonTitle
	}

	var numberOfPages: Int {
		OnboardingPage.fullOnboarding.count
	}
}
