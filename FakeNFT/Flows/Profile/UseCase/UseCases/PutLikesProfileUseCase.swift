import Foundation

protocol PutLikesProfileUseCase {
	func invoke(likes: NftIDs, completion: @escaping (Result<NftIDs, FakeNFTError>) -> Void)
}

final class PutLikesProfileUseCaseImp: PutLikesProfileUseCase {
	private let network: APIClient
	private var task: NetworkTask?

	init(apiClient: APIClient) {
		self.network = apiClient
	}

	func invoke(likes: NftIDs, completion: @escaping (Result<NftIDs, FakeNFTError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = FakeNFTAPI.putProfile
		let request = PostRequest(
			endpoint: resource.url,
			body: LikesDTO(likes: likes.nfts),
			method: .put
		)

		task = network.send(request) { [weak self] ( result: Result<ProfileDTO, APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let profileDTO):
				let likesDTO = profileDTO.likes ?? []
				if likesDTO == likes.nfts {
					completion(.success(.init(nfts: likesDTO)))
				} else {
					completion(.failure(.brokenLikes))
				}
				self.task = nil
			case .failure(let error):
				completion(.failure(.apiError(error)))
				self.task = nil
			}
		}
	}
}
