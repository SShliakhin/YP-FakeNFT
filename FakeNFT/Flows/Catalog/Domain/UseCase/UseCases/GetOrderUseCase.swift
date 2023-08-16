import Foundation

protocol GetOrderUseCase {
	func invoke(completion: @escaping (Result<NftIDs, APIError>) -> Void)
}

final class GetOrderUseCaseImp: GetOrderUseCase {
	private let network: APIClient
	private var task: NetworkTask?

	init(apiClient: APIClient) {
		self.network = apiClient
	}

	func invoke(completion: @escaping (Result<NftIDs, APIError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = CatalogAPI.getOrder
		let request = Request(endpoint: resource.url)

		task = network.send(request) { [weak self] ( result: Result<OrderDTO, APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let orderDTO):
				let order = orderDTO.nfts ?? []
				completion(.success(.init(nfts: order)))
				self.task = nil
			case .failure(let error):
				completion(.failure(error))
				self.task = nil
			}
		}
	}
}
