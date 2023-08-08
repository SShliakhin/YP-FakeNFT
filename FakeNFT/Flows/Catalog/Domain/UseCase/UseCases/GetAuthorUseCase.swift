import Foundation

final class GetAuthorUseCase {
	private let network: APIClient
	private var task: NetworkTask?

	init(apiClient: APIClient) {
		self.network = apiClient
	}

	func invoke(userID: String, completion: @escaping (Result<Author, APIError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = CatalogAPI.getUser(userID)
		let request = Request(endpoint: resource.url)

		task = network.send(request) { [weak self] ( result: Result<UserDTO, APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let userDTO):
				if let author = Author(from: userDTO) {
					completion(.success(author))
				} else {
					completion(.failure(.unknownResponse))
				}
				self.task = nil
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
}
