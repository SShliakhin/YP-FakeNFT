import Foundation

protocol PutLikesProfileUseCase {
	func invoke(likes: NftIDs, completion: @escaping (Result<NftIDs, FakeNFTError>) -> Void)
}

final class PutLikesProfileUseCaseImp: PutLikesProfileUseCase {
	private let network: APIClient
	private var task: NetworkTask?
	private var profileRepository: ProfileRepository

	init(
		apiClient: APIClient,
		profileRepository: ProfileRepository
	) {
		self.network = apiClient
		self.profileRepository = profileRepository
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
				if let profile = profileDTO.toDomain() {
					self.profileRepository.profile.value = profile
					if profile.likes == likes.nfts {
						self.profileRepository.likes.value = profile.likes
						completion(.success(.init(nfts: profile.likes)))
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
