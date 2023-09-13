import Foundation

protocol PutProfileUseCase {
	func invoke(body: ProfileBody, completion: @escaping (Result<Bool, FakeNFTError>) -> Void)
}

final class PutProfileUseCaseImp: PutProfileUseCase {
	private let network: APIClient
	private var task: NetworkTask?

	init(apiClient: APIClient) {
		self.network = apiClient
	}

	func invoke(body: ProfileBody, completion: @escaping (Result<Bool, FakeNFTError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = FakeNFTAPI.putProfile
		let request = PostRequest(
			endpoint: resource.url,
			body: body,
			method: .put
		)

		task = network.send(request) { [weak self] ( result: Result<ProfileDTO, APIError>) in
			guard let self = self else { return }
			switch result {
			case .success:
				completion(.success(true))
				self.task = nil
			case .failure(let error):
				completion(.failure(.apiError(error)))
				self.task = nil
			}
		}
	}
}
