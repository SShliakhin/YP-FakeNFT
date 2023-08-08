import Foundation

final class GetCollectionUseCase {
	private let network: APIClient
	private var task: NetworkTask?

	init(apiClient: APIClient) {
		self.network = apiClient
	}

	func invoke(collectionID: String, completion: @escaping (Result<Collection, APIError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = CatalogAPI.getCollection(collectionID)
		let request = Request(endpoint: resource.url)

		task = network.send(request) { [weak self] ( result: Result<CollectionDTO, APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let collectionDTO):
				if let collection = Collection(from: collectionDTO) {
					completion(.success(collection))
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
