import Foundation

protocol Model: Codable {
	static var decoder: JSONDecoder { get }
	static var encoder: JSONEncoder { get }
}

extension Model {
	static var decoder: JSONDecoder {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
	}

	static var encoder: JSONEncoder {
		let encoder = JSONEncoder()
		encoder.keyEncodingStrategy = .convertToSnakeCase
		return encoder
	}
}

extension String: Model {}
