import Foundation

protocol AppContextOut {
	var isFirstStart: Bool { get }
	var authDate: Date { get }
}

protocol AppContextIn {
	func setFirstStart()
	func setAuthDate()
}

// class or struct???
final class AppContextImp: AppContextOut {
	@UserDefaultsBacked(key: "first-start")
	var isFirstStart = true

	@UserDefaultsBacked(key: "auth-date")
	// swiftlint:disable:next force_unwrapping
	var authDate: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
}

// MARK: - ContextIn
extension AppContextImp: AppContextIn {
	func setFirstStart() {
		isFirstStart = false
	}

	func setAuthDate() {
		authDate = Date()
	}
}

typealias AppContext = AppContextIn & AppContextOut
