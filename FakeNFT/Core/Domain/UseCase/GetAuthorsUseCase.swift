import Foundation

protocol GetAuthorsUseCase {
	func invoke(authorID: String, completion: @escaping (Result<Author, FakeNFTError>) -> Void)
	func invoke(authorIDs: [String], completion: @escaping (Result<[Author], FakeNFTError>) -> Void)
}

final class GetAuthorsUseCaseImp: GetAuthorsUseCase {
	private let network: APIClient
	private var task: NetworkTask?

	init( apiClient: APIClient) {
		self.network = apiClient
	}

	func invoke(authorID: String, completion: @escaping (Result<Author, FakeNFTError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = FakeNFTAPI.getUser(authorID)
		let request = Request(endpoint: resource.url)

		task = network.send(request) { [weak self] ( result: Result<UserDTO, APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let userDTO):
				if let author = userDTO.toDomainAuthor() {
					completion(.success(author))
				} else {
					completion(.failure(.noAuthorByID(authorID)))
				}
				self.task = nil
			case .failure(let error):
				completion(.failure(.apiError(error)))
				self.task = nil
			}
		}
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
				let users = usersDTO.compactMap { $0.toDomainAuthor() }
				if users.isEmpty {
					completion(.failure(.noAuthors))
				} else {
					let authors = users.filter { authorIDs.contains($0.id) }
					completion(.success(authors))
				}
				self.task = nil
			case .failure(let error):
				completion(.failure(.apiError(error)))
				self.task = nil
			}
		}
	}
}
