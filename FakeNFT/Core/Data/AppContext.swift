import Foundation

protocol AppContextOut {
	var isFirstStart: Bool { get }
	var authDate: Date { get }
}

protocol AppContextIn {
	func setFirstStart()
	func setAuthDate()
	func reset()
}

final class AppContextImp: AppContextOut {
	@UserDefaultsBacked(key: "first-start")
	var isFirstStart = true

	@UserDefaultsBacked(key: "auth-date")
	var authDate: Date = Appearance.initDate
}

// MARK: - ContextIn
extension AppContextImp: AppContextIn {
	func setFirstStart() {
		isFirstStart = false
	}

	func setAuthDate() {
		authDate = Date()
	}

	func reset() {
		isFirstStart = true
		authDate = Appearance.initDate
	}
}

typealias AppContext = AppContextIn & AppContextOut

private extension AppContextImp {
	enum Appearance {
		// swiftlint:disable:next force_unwrapping
		static let initDate: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
	}
}
