import Foundation

protocol SearchNftsByNameUseCase {
	func invoke(searchText: String, completion: @escaping (Result<[Nft], FakeNFTError>) -> Void)
}

final class SearchNftsByNameUseCaseImp: SearchNftsByNameUseCase {
	private let network: APIClient
	private var task: NetworkTask?

	init(apiClient: APIClient) {
		self.network = apiClient
	}

	func invoke(searchText: String, completion: @escaping (Result<[Nft], FakeNFTError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = FakeNFTAPI.searchNFTsByTitle(searchText)
		let request = Request(endpoint: resource.url)

		task = network.send(request) { [weak self] ( result: Result<[NftDTO], APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let nftsDTO):
				let nfts = nftsDTO.compactMap { $0.toDomain() }
				completion(.success(nfts))
				self.task = nil
			case .failure(let error):
				completion(.failure(.apiError(error)))
				self.task = nil
			}
		}
	}
}
