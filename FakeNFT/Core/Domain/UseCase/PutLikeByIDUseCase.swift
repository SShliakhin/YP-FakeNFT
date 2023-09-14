import Foundation

protocol PutLikeByIDUseCase {
	func invoke(_ id: String, completion: @escaping (Result<Bool, FakeNFTError>) -> Void)
}

final class PutLikeByIDUseCaseImp: PutLikeByIDUseCase {
	private let network: APIClient
	private var task: NetworkTask?
	private var likesIDsRepository: NftsIDsRepository

	init(
		apiClient: APIClient,
		likesIDsRepository: NftsIDsRepository
	) {
		self.network = apiClient
		self.likesIDsRepository = likesIDsRepository
	}

	func invoke(_ id: String, completion: @escaping (Result<Bool, FakeNFTError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		var likes = likesIDsRepository.items.value
		if likes.contains(id) {
			likes.removeAll { $0 == id }
		} else {
			likes.append(id)
		}

		let resource = FakeNFTAPI.putProfile
		let request = PostRequest(
			endpoint: resource.url,
			body: LikesDTO(likes: likes),
			method: .put
		)

		task = network.send(request) { [weak self] ( result: Result<ProfileDTO, APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let profileDTO):
				if let profile = profileDTO.toDomain() {
					if profile.likes == likes {
						self.likesIDsRepository.putItems(nftIDs: profile.likes)
						completion(.success(true))
					} else {
						completion(.failure(.brokenLikes))
					}
				} else {
					completion(.failure(.noProfile))
				}
				self.task = nil
			case .failure(let error):
				completion(.failure(.apiError(error)))
				self.task = nil
			}
		}
	}
}
