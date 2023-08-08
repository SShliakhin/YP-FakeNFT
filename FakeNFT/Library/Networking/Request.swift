import Foundation

protocol IRequest {
	func urlRequest() -> URLRequest
}

struct PostRequest<Body: Model>: IRequest {
	let endpoint: URL?
	let method: HTTPMethod
	let body: Body

	init(endpoint: URL?, body: Body, method: HTTPMethod = .post) {
		self.endpoint = endpoint
		self.body = body
		self.method = method
	}

	func urlRequest() -> URLRequest {
		guard let url = endpoint else {
			print("Failed to create request url")
			return URLRequest(url: URL(fileURLWithPath: ""))
		}

		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = method.rawValue.uppercased()

		do {
			let encoder = Body.encoder
			let data = try encoder.encode(body)
			urlRequest.httpBody = data
			urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
		} catch {
			assertionFailure("Error encoding request body: \(error)")
		}

		return urlRequest
	}
}

struct Request: IRequest {
	let endpoint: URL?
	let method: HTTPMethod

	init(endpoint: URL?, method: HTTPMethod = .get) {
		self.endpoint = endpoint
		self.method = method
	}

	func urlRequest() -> URLRequest {
		guard let url = endpoint else {
			print("Failed to create request url")
			return URLRequest(url: URL(fileURLWithPath: ""))
		}

		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = method.rawValue.uppercased()

		return urlRequest
	}
}

// MARK: - IRequest

extension URLRequest: IRequest {
	func urlRequest() -> URLRequest {
		return self
	}
}

// MARK: - HTTPMethod

enum HTTPMethod: String {
	case delete
	case get
	case patch
	case post
	case put
}
