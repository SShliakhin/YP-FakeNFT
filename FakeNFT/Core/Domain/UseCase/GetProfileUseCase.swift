import Foundation

protocol GetProfileUseCase {
	func invoke(completion: @escaping (Result<Profile, FakeNFTError>) -> Void)
}

final class GetProfileUseCaseImp: GetProfileUseCase {
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

	func invoke(completion: @escaping (Result<Profile, FakeNFTError>) -> Void) {
		if let profile = profileRepository.profile.value {
			completion(.success(profile))
			return
		}

		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = FakeNFTAPI.getProfile
		let request = Request(endpoint: resource.url)

		task = network.send(request) { [weak self] ( result: Result<ProfileDTO, APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let profileDTO):
				if let profile = Profile(from: profileDTO) {
					self.profileRepository.profile.value = profile
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
