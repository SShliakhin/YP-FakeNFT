import Foundation

protocol GetAuthorUseCase {
	func invoke(userID: String, completion: @escaping (Result<Author, GetAuthorError>) -> Void)
}

enum GetAuthorError: Error {
	case noAuthorByID(String)
	case apiError(APIError)
}

extension GetAuthorError: CustomStringConvertible {
	private var localizedDescription: String {
		switch self {
		case .noAuthorByID(let id):
			return String(format: Appearance.noAuthorByID, id)
		case .apiError(let apiError):
			return apiError.description
		}
	}

	var description: String {
		localizedDescription
	}
}

private extension GetAuthorError {
	enum Appearance {
		static let noAuthorByID = "Автор с id %@ не получен."
	}
}

final class GetAuthorUseCaseImp: GetAuthorUseCase {
	private let network: APIClient
	private var task: NetworkTask?

	init(apiClient: APIClient) {
		self.network = apiClient
	}

	func invoke(userID: String, completion: @escaping (Result<Author, GetAuthorError>) -> Void) {
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
					completion(.failure(.noAuthorByID(userID)))
				}
				self.task = nil
			case .failure(let error):
				completion(.failure(.apiError(error)))
			}
		}
	}
}
