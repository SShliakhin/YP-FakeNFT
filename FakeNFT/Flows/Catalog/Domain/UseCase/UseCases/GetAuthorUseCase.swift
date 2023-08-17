import Foundation

protocol GetAuthorUseCase {
	func invoke(userID: String, completion: @escaping (Result<Author, CatalogError>) -> Void)
}

final class GetAuthorUseCaseImp: GetAuthorUseCase {
	private let network: APIClient
	private var task: NetworkTask?

	init(apiClient: APIClient) {
		self.network = apiClient
	}

	func invoke(userID: String, completion: @escaping (Result<Author, CatalogError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = FakeNFTAPI.getUser(userID)
		let request = Request(endpoint: resource.url)

		task = network.send(request) { [weak self] ( result: Result<UserDTO, APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let userDTO):
				if let author = Author(from: userDTO) {
					completion(.success(author))
				} else {
					completion(.failure(.noAuthorByID(userID)))
				}
				self.task = nil
			case .failure(let error):
				completion(.failure(.apiError(error)))
				self.task = nil
			}
		}
	}
}
