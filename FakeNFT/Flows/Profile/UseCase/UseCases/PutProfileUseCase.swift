import Foundation

protocol PutProfileUseCase {
	func invoke(profile: Profile, completion: @escaping (Result<Profile, FakeNFTError>) -> Void)
}

final class PutProfileUseCaseImp: PutProfileUseCase {
	private let network: APIClient
	private var task: NetworkTask?

	init(apiClient: APIClient) {
		self.network = apiClient
	}

	func invoke(profile: Profile, completion: @escaping (Result<Profile, FakeNFTError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = FakeNFTAPI.putProfile
		let request = PostRequest(
			endpoint: resource.url,
			body: ProfileDTO(
				name: profile.name,
				avatar: profile.avatar?.absoluteString,
				description: profile.description,
				website: profile.website?.absoluteString,
				nfts: profile.nfts,
				likes: profile.likes
			),
			method: .put
		)

		task = network.send(request) { [weak self] ( result: Result<ProfileDTO, APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let profileDTO):
				if let profile = Profile(from: profileDTO) {
					completion(.success(profile))
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
