import Foundation

protocol IDataConvert {
	static func convert(from data: Data?) throws -> Self
}

struct Empty: IDataConvert {
	static func convert(from data: Data?) throws -> Empty {
		return Empty()
	}
}

extension Optional: IDataConvert where Wrapped == Data {
	static func convert(from data: Data?) throws -> Data? {
		return data
	}
}

protocol IRequiredDataConvert: IDataConvert {
	static func convert(from data: Data) throws -> Self
}

extension IRequiredDataConvert {
	static func convert(from data: Data?) throws -> Self {
		if let data = data {
			return try convert(from: data)
		} else {
			throw APIError.dataConversionError("Failed to get data from the server.")
		}
	}
}

extension Data: IRequiredDataConvert {
	static func convert(from data: Data) throws -> Data {
		return data
	}
}

extension String: IRequiredDataConvert {
	static func convert(from data: Data) throws -> String {
		if let result = String(data: data, encoding: .utf8) {
			return result
		} else {
			throw APIError.dataConversionError("Failed to parse data into a utf8 string.")
		}
	}
}

struct DecodableConvert<T: Model>: IRequiredDataConvert {
	let model: T

	init(_ model: T) {
		self.model = model
	}

	static func convert(from data: Data) throws -> DecodableConvert<T> {
		let decoder = T.decoder
		let model = try decoder.decode(T.self, from: data)
		return DecodableConvert(model)
	}
}

struct DecodableArrayConvert<T: Model>: IRequiredDataConvert {
	let models: [T]

	init(_ models: [T]) {
		self.models = models
	}

	static func convert(from data: Data) throws -> DecodableArrayConvert<T> {
		let decoder = T.decoder
		let models = try decoder.decode([T].self, from: data)
		return DecodableArrayConvert(models)
	}
}
