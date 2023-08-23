import Foundation

extension Theme {
	// MARK: - NumberFormatter
	static func getPriceStringFromDouble(
		_ amount: Double,
		separator: String = ",",
		currency: String = "ETH"
	) -> String {
		let (dollars, cents) = modf(amount)

		let dollarsString = String(format: "%.0f", dollars)
		let centsString = cents == 0
		? "00"
		: String(format: "%.0f", cents * 100)

		return "\(dollarsString)\(separator)\(centsString) \(currency)"
	}
}
