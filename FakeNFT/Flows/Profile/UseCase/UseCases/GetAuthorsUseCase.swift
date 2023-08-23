import Foundation

protocol GetAuthorsUseCase {
	func invoke(authorIDs: [String], completion: @escaping (Result<[Author], FakeNFTError>) -> Void)
}

final class GetAuthorsUseCaseImp: GetAuthorsUseCase {
	private let network: APIClient
	private var task: NetworkTask?

	init(apiClient: APIClient) {
		self.network = apiClient
	}

	func invoke(authorIDs: [String], completion: @escaping (Result<[Author], FakeNFTError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = FakeNFTAPI.getUsers
		let request = Request(endpoint: resource.url)

		task = network.send(request) { [weak self] ( result: Result<[UserDTO], APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let usersDTO):
				let users = usersDTO.compactMap { Author(from: $0) }
				if users.isEmpty {
					completion(.failure(.noAuthors))
				} else {
					let newUsers = users.filter { authorIDs.contains($0.id) }
					completion(.success(newUsers))
				}
				self.task = nil
			case .failure(let error):
				completion(.failure(.apiError(error)))
				self.task = nil
			}
		}
	}
}
