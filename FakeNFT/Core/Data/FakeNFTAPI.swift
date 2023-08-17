import Foundation

extension String {
	static func key(_ constant: FakeNFTAPI.Constant) -> Self { constant.rawValue }
}

enum FakeNFTAPI {
	enum Constant: String {
		case baseURLString = "64d15caaff953154bb7a4558.mockapi.io"
	}

	case getCollections(SortCollectionsBy)
	case getCollection(String)
	case getNFTs
	case getNFT(String)
	case getOrder
	case putOrder
	case getProfile
	case putProfile
	case getUser(String)
	case getNFTsByAuthor(String)
}

extension FakeNFTAPI: API {
	var scheme: HTTPScheme {
		.https
	}

	var baseURL: String {
		.key(.baseURLString)
	}

	var path: String {
		switch self {
		case .getCollections:
			return "/api/v1/collections"
		case let .getCollection(id):
			return "/api/v1/collections/\(id)"
		case .getNFTs:
			return "/api/v1/nft"
		case let .getNFT(id):
			return "/api/v1/nft/\(id)"
		case .getOrder, .putOrder:
			return "/api/v1/orders/1"
		case .getProfile, .putProfile:
			return "/api/v1/profile/1"
		case let .getUser(id):
			return "/api/v1/users/\(id)"
		case .getNFTsByAuthor:
			return "/api/v1/nft"
		}
	}

	var parameters: [URLQueryItem]? {
		switch self {
		case .getCollections(let sortBy):
			switch sortBy {
			case .name:
				return [
					URLQueryItem(name: "sortBy", value: "name"),
					URLQueryItem(name: "order", value: "asc")
				]
			case .nftsCount:
				return nil
			}
		case .getNFTsByAuthor(let id):
			return [
				URLQueryItem(name: "author", value: id)
			]
		default:
			return nil
		}
	}
}

enum CatalogError: Error {
	case apiError(APIError)
	case noCollections
	case noAuthorByID(String)
	case noNfts
	case noNftsByAuthorID(String)
	case noNftByID(String)
	case brokenLikes
	case brokenOrder
}

extension CatalogError: CustomStringConvertible {
	private var localizedDescription: String {
		switch self {
		case .apiError(let apiError):
			return apiError.description
		case .noCollections:
			return Appearance.noCollection
		case .noNfts:
			return Appearance.noNfts
		case .noNftsByAuthorID(let authorID):
			return String(format: Appearance.noNftsByAuthorID, authorID)
		case .noNftByID(let id):
			return String(format: Appearance.noNftByID, id)
		case .noAuthorByID(let id):
			return String(format: Appearance.noAuthorByID, id)
		case .brokenLikes:
			return Appearance.brokenLikes
		case .brokenOrder:
			return Appearance.brokenOrder
		}
	}

	var description: String {
		localizedDescription
	}
}

private extension CatalogError {
	enum Appearance {
		static let noCollection = "Коллекции не получены."
		static let noNfts = "Nfts не получены."
		static let noNftsByAuthorID = "Nfts по автору с id %@ не получены."
		static let noNftByID = "Nft с id %@ не получен."
		static let noAuthorByID = "Автор с id %@ не получен."
		static let brokenLikes = "Лайки сломаны."
		static let brokenOrder = "Заказ сломан"
	}
}
