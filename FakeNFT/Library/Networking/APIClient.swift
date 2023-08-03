import UIKit

struct APIClient {
	private let session: URLSession
	private let queue: DispatchQueue

	init(session: URLSession) {
		self.session = session
		self.queue = DispatchQueue(label: "SimpleNetworking", qos: .userInitiated, attributes: .concurrent)
	}

	@discardableResult
	func send<T: Model>(
		_ request: IRequest,
		completion: @escaping (Result<T, APIError>) -> Void
	) -> NetworkTask {

		return send(request) { (result: Result<DecodableConvert<T>, APIError>) in
			completion(result.map { $0.model })
		}
	}

	@discardableResult
	func send<T: IDataConvert>(
		_ request: IRequest,
		completion: @escaping (Result<T, APIError>) -> Void
	) -> NetworkTask {

		return send(
			request,
			taskCreator: { urlRequest, completion in
				self.session.dataTask(with: urlRequest, completionHandler: completion)
			},
			dataConvertor: { try T.convert(from: $0) },
			completion: completion
		)
	}

	private func send<DataType, ReturnType>(
		_ request: IRequest,
		taskCreator: @escaping ((URLRequest, @escaping (DataType?, URLResponse?, Error?) -> Void) -> URLSessionTask),
		dataConvertor: @escaping (DataType?) throws -> ReturnType,
		completion: @escaping (Result<ReturnType, APIError>) -> Void
	) -> NetworkTask {

		let networkTask = NetworkTask()

		let backgroundTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)

		// swiftlint:disable:next closure_body_length
		queue.async {
			let urlRequest = request.urlRequest()

			let urlToLog = urlRequest.url?.absoluteString ?? ""
			print("Send: \(urlToLog) - \(urlRequest.httpMethod ?? "")")

			let task = taskCreator(urlRequest) { data, response, error in
				let result: Result<ReturnType, APIError>

				if let error = error {
					result = .failure(.networkError(error))
				} else if let apiError = APIError.error(from: response) {
					result = .failure(apiError)
				} else {
					do {
						result = .success(try dataConvertor(data))
					} catch let error as DecodingError {
						result = .failure(.decodingError(error))
					} catch {
						result = .failure(.unhandledResponse)
					}
				}

				switch result {
				case .success:
					print("Request succeeded: \(urlToLog)")
				case .failure(let error):
					print("Request failed: \(urlToLog) - \(error)")
				}

				DispatchQueue.main.async {
					completion(result)

					UIApplication.shared.endBackgroundTask(backgroundTaskID)
				}
			}

			task.resume()

			networkTask.set(task)
		}

		return networkTask
	}
}
