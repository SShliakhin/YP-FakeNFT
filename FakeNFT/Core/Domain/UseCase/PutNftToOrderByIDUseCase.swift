import Foundation

protocol PutNftToOrderByIDUseCase {
	func invoke(_ id: String, completion: @escaping (Result<Bool, FakeNFTError>) -> Void)
}

final class PutNftToOrderByIDUseCaseImp: PutNftToOrderByIDUseCase {
	private let network: APIClient
	private var task: NetworkTask?
	private var orderIDsRepository: NftsIDsRepository

	init(
		apiClient: APIClient,
		orderIDsRepository: NftsIDsRepository
	) {
		self.network = apiClient
		self.orderIDsRepository = orderIDsRepository
	}

	func invoke(_ id: String, completion: @escaping (Result<Bool, FakeNFTError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		var order = orderIDsRepository.items.value
		if order.contains(id) {
			order.removeAll { $0 == id }
		} else {
			order.append(id)
		}

		let resource = FakeNFTAPI.putOrder
		let request = PostRequest(
			endpoint: resource.url,
			body: OrderDTO(nfts: order),
			method: .put
		)

		task = network.send(request) { [weak self] ( result: Result<OrderDTO, APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let orderDTO):
				guard let orderDTO = orderDTO.nfts else { return completion(.failure(.brokenOrder)) }
				if orderDTO == order {
					self.orderIDsRepository.items.value = order
					completion(.success(true))
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
