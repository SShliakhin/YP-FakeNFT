import Foundation

protocol API {
	var scheme: HTTPScheme { get }
	var baseURL: String { get }
	var path: String { get }
	var parameters: [URLQueryItem]? { get }
}

extension API {
	var url: URL? {
		var components = URLComponents()
		components.scheme = scheme.rawValue
		components.host = baseURL
		components.path = path
		if let parameters = parameters {
			components.queryItems = parameters
		}
		return components.url
	}
}

// MARK: - HTTPScheme

enum HTTPScheme: String {
	case http
	case https
}
