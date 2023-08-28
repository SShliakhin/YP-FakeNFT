import Foundation

protocol GetNftsProfileUseCase {
	func invoke(nftIDs: [String], completion: @escaping (Result<[Nft], FakeNFTError>) -> Void)
	func invoke(sortBy: SortMyNftsBy, nftIDs: [String], completion: @escaping (Result<[Nft], FakeNFTError>) -> Void)
	func invoke(authorID: String, completion: @escaping (Result<[Nft], FakeNFTError>) -> Void)
	func invoke(nftID: String, completion: @escaping (Result<Nft, FakeNFTError>) -> Void)
}

final class GetNftsProfileUseCaseImp: GetNftsProfileUseCase {
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

	func invoke(nftIDs: [String], completion: @escaping (Result<[Nft], FakeNFTError>) -> Void) {
		invoke(sortBy: .rating, nftIDs: nftIDs, completion: completion)
	}

	func invoke(sortBy: SortMyNftsBy, nftIDs: [String], completion: @escaping (Result<[Nft], FakeNFTError>) -> Void) {
		if let nfts = profileRepository.getNftByIDs(nftIDs) {
			completion(.success(nfts))
			return
		}

		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = FakeNFTAPI.getNFTs(sortBy)
		let request = Request(endpoint: resource.url)

		task = network.send(request) { [weak self] ( result: Result<[NftDTO], APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let nftsDTO):
				let nfts = nftsDTO.compactMap { Nft(from: $0) }
				if nfts.isEmpty {
					completion(.failure(.noNfts))
				} else {
					let newNfts = nfts.filter { nftIDs.contains($0.id) }
					self.profileRepository.addNfts(newNfts)
					completion(.success(newNfts))
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
		if let nft = profileRepository.getNftByID(nftID) {
			completion(.success(nft))
			return
		}

		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = FakeNFTAPI.getNFT(nftID)
		let request = Request(endpoint: resource.url)

		task = network.send(request) { [weak self] ( result: Result<NftDTO, APIError>) in
			guard let self = self else { return }
			switch result {
			case .success(let nftDTO):
				if let nft = Nft(from: nftDTO) {
					self.profileRepository.addNft(nft)
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
