import Foundation

enum APIError: Error {
	case unknownResponse
	case networkError(Error)
	case requestError(Int)
	case serverError(Int)
	case decodingError(DecodingError)
	case dataConversionError(String)
	case noImageURL
	case unhandledResponse
}

extension APIError: CustomStringConvertible {
	static func error(from response: URLResponse?) -> APIError? {
		guard let http = response as? HTTPURLResponse else {
			return .unknownResponse
		}

		switch http.statusCode {
		case 200...299: // swiftlint:disable:this numbers_smell
			return nil
		case 400...499: // swiftlint:disable:this numbers_smell
			return .requestError(http.statusCode)
		case 500...599: // swiftlint:disable:this numbers_smell
			return .serverError(http.statusCode)
		default:
			return .unhandledResponse
		}
	}

	private var localizedDescription: String {
		switch self {
		case .unknownResponse:
			return "Unknown Response"
		case .networkError(let error):
			return "Network Error: \(error.localizedDescription)"
		case .requestError(let statusCode):
			return "HTTP \(statusCode)"
		case .serverError(let statusCode):
			return "Server error (HTTP \(statusCode))"
		case .decodingError(let decodingError):
			return "Decoding error: \(decodingError)"
		case .dataConversionError(let message):
			return "\(message)"
		case .noImageURL:
			return "No image URL"
		case .unhandledResponse:
			return "Unhandled response"
		}
	}

	var description: String {
		localizedDescription
	}
}
