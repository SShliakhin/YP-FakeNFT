import Foundation

protocol GetLikesUseCase {
	func invoke(completion: @escaping (Result<NftIDs, APIError>) -> Void)
}

final class GetLikesUseCaseImp: GetLikesUseCase {
	private let network: APIClient
	private var task: NetworkTask?

	init(apiClient: APIClient) {
		self.network = apiClient
	}

	func invoke(completion: @escaping (Result<NftIDs, APIError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = CatalogAPI.getProfile
		let request = Request(endpoint: resource.url)

		task = network.send(request) { [weak self] ( result: Result<ProfileDTO, APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let profileDTO):
				let likes = profileDTO.likes ?? []
				completion(.success(.init(nfts: likes)))
				self.task = nil
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
}
