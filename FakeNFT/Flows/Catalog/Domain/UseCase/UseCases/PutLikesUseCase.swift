import Foundation

final class PutLikesUseCase {
	private let network: APIClient
	private var task: NetworkTask?

	init(apiClient: APIClient) {
		self.network = apiClient
	}

	func invoke(likes: NftIDs, completion: @escaping (Result<NftIDs, APIError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = CatalogAPI.putProfile
		let request = PostRequest(
			endpoint: resource.url,
			body: LikesDTO(likes: likes.nfts),
			method: .put
		)

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
