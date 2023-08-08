import Foundation

final class GetNftsUseCase {
	private let network: APIClient
	private var task: NetworkTask?

	init(apiClient: APIClient) {
		self.network = apiClient
	}

	func invoke(completion: @escaping (Result<[Nft], APIError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = CatalogAPI.getNFTs
		let request = Request(endpoint: resource.url)

		task = network.send(request) { [weak self] ( result: Result<[NftDTO], APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let nftsDTO):
				let nfts = nftsDTO.compactMap { Nft(from: $0) }
				completion(.success(nfts))
				self.task = nil
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	func invoke(authorID: String, completion: @escaping (Result<[Nft], APIError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = CatalogAPI.getNFTsByAuthor(authorID)
		let request = Request(endpoint: resource.url)

		task = network.send(request) { [weak self] ( result: Result<[NftDTO], APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let nftsDTO):
				let nfts = nftsDTO.compactMap { Nft(from: $0) }
				completion(.success(nfts))
				self.task = nil
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	func invoke(nftID: String, completion: @escaping (Result<Nft, APIError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = CatalogAPI.getNFT(nftID)
		let request = Request(endpoint: resource.url)

		task = network.send(request) { [weak self] ( result: Result<NftDTO, APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let nftDTO):
				if let nft = Nft(from: nftDTO) {
					completion(.success(nft))
				} else {
					completion(.failure(.unknownResponse))
				}
				self.task = nil
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
}