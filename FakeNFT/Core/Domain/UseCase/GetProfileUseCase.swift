import Foundation

protocol GetProfileUseCase {
	func invoke(completion: @escaping (Result<Profile, FakeNFTError>) -> Void)
}

final class GetProfileUseCaseImp: GetProfileUseCase {
	private let network: APIClient
	private var task: NetworkTask?

	init(apiClient: APIClient) {
		self.network = apiClient
	}

	func invoke(completion: @escaping (Result<Profile, FakeNFTError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = FakeNFTAPI.getProfile
		let request = Request(endpoint: resource.url)

		task = network.send(request) { [weak self] ( result: Result<ProfileDTO, APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let profileDTO):
				if let profile = profileDTO.toDomain() {
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

final class GetProfileWithMonitor: GetProfileUseCase {
	private let getProfile: GetProfileUseCase
	private let networkMonitor: NetworkMonitor

	init(getProfile: GetProfileUseCase, networkMonitor: NetworkMonitor) {
		self.getProfile = getProfile
		self.networkMonitor = networkMonitor
	}

	func invoke(completion: @escaping (Result<Profile, FakeNFTError>) -> Void) {
		if !networkMonitor.isConnected {
			completion(.failure(.notConnectedToInternet))
		}

		getProfile.invoke(completion: completion)
	}
}
