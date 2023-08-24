import Foundation

// TODO: - перенести в Theme
extension Theme {
	// MARK: - замена NumberFormatter
	static func getPriceStringFromDouble(
		_ amount: Double,
		separator: String = ",",
		currency: String = "ETH"
	) -> String {
		let (dollars, cents) = modf(amount)

		let dollarsString = String(format: "%.0f", dollars)
		let centsString = String(format: "%02.0f", cents * 100)

		return "\(dollarsString)\(separator)\(centsString) \(currency)"
	}
}
