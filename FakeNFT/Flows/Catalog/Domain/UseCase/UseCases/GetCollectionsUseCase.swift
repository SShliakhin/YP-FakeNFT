import Foundation

protocol GetCollectionsUseCase {
	func invoke(completion: @escaping (Result<[Collection], GetCollectionsError>) -> Void)
}

enum GetCollectionsError: Error {
	case noCollections
	case apiError(APIError)
}

extension GetCollectionsError: CustomStringConvertible {
	private var localizedDescription: String {
		switch self {
		case .noCollections:
			return Appearance.noCollection
		case .apiError(let apiError):
			return apiError.description
		}
	}

	var description: String {
		localizedDescription
	}
}

private extension GetCollectionsError {
	enum Appearance {
		static let noCollection = "Коллекции не получены."
	}
}

final class GetCollectionsUseCaseImp: GetCollectionsUseCase {
	private let network: APIClient
	private var task: NetworkTask?

	init(apiClient: APIClient) {
		self.network = apiClient
	}

	func invoke(completion: @escaping (Result<[Collection], GetCollectionsError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = CatalogAPI.getCollections
		let request = Request(endpoint: resource.url)

		task = network.send(request) { [weak self] ( result: Result<[CollectionDTO], APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let collectionsDTO):
				let collections = collectionsDTO.compactMap { Collection(from: $0) }
				if collections.isEmpty {
					completion(.failure(.noCollections))
				} else {
					completion(.success(collections))
				}
				self.task = nil
			case .failure(let error):
				completion(.failure(.apiError(error)))
			}
		}
	}
}
