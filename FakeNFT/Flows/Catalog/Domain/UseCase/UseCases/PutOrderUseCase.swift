import Foundation

protocol PutOrderUseCase {
	func invoke(order: NftIDs, completion: @escaping (Result<NftIDs, CatalogError>) -> Void)
}

final class PutOrderUseCaseImp: PutOrderUseCase {
	private let network: APIClient
	private var task: NetworkTask?

	init(apiClient: APIClient) {
		self.network = apiClient
	}

	func invoke(order: NftIDs, completion: @escaping (Result<NftIDs, CatalogError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = FakeNFTAPI.putOrder
		let request = PostRequest(
			endpoint: resource.url,
			body: OrderDTO(nfts: order.nfts),
			method: .put
		)

		task = network.send(request) { [weak self] ( result: Result<OrderDTO, APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let orderDTO):
				let orderDTO = orderDTO.nfts ?? []
				if orderDTO == order.nfts {
					completion(.success(.init(nfts: orderDTO)))
				} else {
					completion(.failure(.brokenOrder))
				}
				self.task = nil
			case .failure(let error):
				completion(.failure(.apiError(error)))
				self.task = nil
			}
		}
	}
}
