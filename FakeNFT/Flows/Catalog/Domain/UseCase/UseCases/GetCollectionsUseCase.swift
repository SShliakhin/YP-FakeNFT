import Foundation

final class GetCollectionsUseCase {
	private let network: APIClient
	private var task: NetworkTask?

	init(apiClient: APIClient) {
		self.network = apiClient
	}

	func invoke(completion: @escaping (Result<[Collection], APIError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = CatalogAPI.getCollections
		let request = Request(endpoint: resource.url)

		task = network.send(request) { [weak self] ( result: Result<[CollectionDTO], APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let collectionsDTO):
				let collections = collectionsDTO.compactMap { Collection(from: $0) }
				completion(.success(collections))
				self.task = nil
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
}
