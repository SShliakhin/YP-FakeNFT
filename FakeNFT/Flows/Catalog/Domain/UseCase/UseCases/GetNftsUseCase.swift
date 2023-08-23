import Foundation

protocol GetNftsUseCase {
	func invoke(completion: @escaping (Result<[Nft], FakeNFTError>) -> Void)
	func invoke(authorID: String, completion: @escaping (Result<[Nft], FakeNFTError>) -> Void)
	func invoke(nftID: String, completion: @escaping (Result<Nft, FakeNFTError>) -> Void)
}

final class GetNftsUseCaseImp: GetNftsUseCase {
	private let network: APIClient
	private var task: NetworkTask?

	init(apiClient: APIClient) {
		self.network = apiClient
	}

	func invoke(completion: @escaping (Result<[Nft], FakeNFTError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = FakeNFTAPI.getNFTs
		let request = Request(endpoint: resource.url)

		task = network.send(request) { [weak self] ( result: Result<[NftDTO], APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let nftsDTO):
				let nfts = nftsDTO.compactMap { Nft(from: $0) }
				if nfts.isEmpty {
					completion(.failure(.noNfts))
				} else {
					completion(.success(nfts))
				}
				self.task = nil
			case .failure(let error):
				completion(.failure(.apiError(error)))
				self.task = nil
			}
		}
	}

	func invoke(authorID: String, completion: @escaping (Result<[Nft], FakeNFTError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = FakeNFTAPI.getNFTsByAuthor(authorID)
		let request = Request(endpoint: resource.url)

		task = network.send(request) { [weak self] ( result: Result<[NftDTO], APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let nftsDTO):
				let nfts = nftsDTO.compactMap { Nft(from: $0) }
				if nfts.isEmpty {
					completion(.failure(.noNftsByAuthorID(authorID)))
				} else {
					completion(.success(nfts))
				}
				self.task = nil
			case .failure(let error):
				completion(.failure(.apiError(error)))
				self.task = nil
			}
		}
	}

	func invoke(nftID: String, completion: @escaping (Result<Nft, FakeNFTError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = FakeNFTAPI.getNFT(nftID)
		let request = Request(endpoint: resource.url)

		task = network.send(request) { [weak self] ( result: Result<NftDTO, APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let nftDTO):
				if let nft = Nft(from: nftDTO) {
					completion(.success(nft))
				} else {
					completion(.failure(.noNftByID(nftID)))
				}
				self.task = nil
			case .failure(let error):
				completion(.failure(.apiError(error)))
				self.task = nil
			}
		}
	}
}