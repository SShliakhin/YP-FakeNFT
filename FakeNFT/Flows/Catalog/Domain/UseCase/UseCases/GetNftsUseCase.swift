import Foundation

protocol GetNftsUseCase {
	func invoke(completion: @escaping (Result<[Nft], GetNftsError>) -> Void)
	func invoke(authorID: String, completion: @escaping (Result<[Nft], GetNftsError>) -> Void)
	func invoke(nftID: String, completion: @escaping (Result<Nft, GetNftsError>) -> Void)
}

enum GetNftsError: Error {
	case noNfts
	case noNftsByAuthorID(String)
	case noNftByID(String)
	case apiError(APIError)
}

extension GetNftsError: CustomStringConvertible {
	private var localizedDescription: String {
		switch self {
		case .noNfts:
			return Appearance.noNfts
		case .noNftsByAuthorID(let authorID):
			return String(format: Appearance.noNftsByAuthorID, authorID)
		case .noNftByID(let id):
			return String(format: Appearance.noNftByID, id)
		case .apiError(let apiError):
			return apiError.description
		}
	}

	var description: String {
		localizedDescription
	}
}

private extension GetNftsError {
	enum Appearance {
		static let noNfts = "Nfts не получены."
		static let noNftsByAuthorID = "Nfts по автору с id %@ не получены."
		static let noNftByID = "Nft с id %@ не получен."
	}
}

final class GetNftsUseCaseImp: GetNftsUseCase {
	private let network: APIClient
	private var task: NetworkTask?

	init(apiClient: APIClient) {
		self.network = apiClient
	}

	func invoke(completion: @escaping (Result<[Nft], GetNftsError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = CatalogAPI.getNFTs
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
			}
		}
	}

	func invoke(authorID: String, completion: @escaping (Result<[Nft], GetNftsError>) -> Void) {
		assert(Thread.isMainThread)
		guard task == nil else { return }

		let resource = CatalogAPI.getNFTsByAuthor(authorID)
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
			}
		}
	}

	func invoke(nftID: String, completion: @escaping (Result<Nft, GetNftsError>) -> Void) {
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
					completion(.failure(.noNftByID(nftID)))
				}
				self.task = nil
			case .failure(let error):
				completion(.failure(.apiError(error)))
			}
		}
	}
}
