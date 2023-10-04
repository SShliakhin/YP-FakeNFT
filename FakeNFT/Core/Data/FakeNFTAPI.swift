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
	case getNFTs(SortMyNftsBy)
	case getNFT(String)
	case getOrder
	case putOrder
	case getProfile
	case putProfile
	case getUser(String)
	case getNFTsByAuthor(String)
	case getCurrencies
	case getCurrency(String)
	case getPaymentCurrency(String)
	case getUsers
	case searchNFTsByTitle(String)
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
		case .getNFTs, .getNFTsByAuthor, .searchNFTsByTitle:
			return "/api/v1/nft"
		case let .getNFT(id):
			return "/api/v1/nft/\(id)"
		case .getOrder, .putOrder:
			return "/api/v1/orders/1"
		case .getProfile, .putProfile:
			return "/api/v1/profile/1"
		case let .getUser(id):
			return "/api/v1/users/\(id)"
		case .getCurrencies:
			return "/api/v1/currencies"
		case let .getCurrency(id):
			return "/api/v1/currencies/\(id)"
		case let .getPaymentCurrency(id):
			return "/api/v1/orders/1/payment/\(id)"
		case .getUsers:
			return "/api/v1/users"
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
		case .getNFTs(let sortBy):
			switch sortBy {
			case .name:
				return [
					URLQueryItem(name: "sortBy", value: "name"),
					URLQueryItem(name: "order", value: "asc")
				]
			case .price:
				return [
					URLQueryItem(name: "sortBy", value: "price"),
					URLQueryItem(name: "order", value: "desc")
				]
			case .rating:
				return [
					URLQueryItem(name: "sortBy", value: "rating"),
					URLQueryItem(name: "order", value: "desc")
				]
			}
		case .getNFTsByAuthor(let id):
			return [
				URLQueryItem(name: "author", value: id)
			]
		case .searchNFTsByTitle(let text):
			return [
				URLQueryItem(name: "name", value: text),
				URLQueryItem(name: "sortBy", value: "name")
			]
		default:
			return nil
		}
	}
}

enum FakeNFTError: Error {
	case apiError(APIError)
	case noCollections
	case noAuthorByID(String)
	case noNfts
	case noNftsByAuthorID(String)
	case noNftByID(String)
	case brokenLikes
	case brokenOrder
	case noProfile
	case noAuthors
	case notConnectedToInternet
}

extension FakeNFTError: CustomStringConvertible {
	private var localizedDescription: String {
		switch self {
		case .apiError(let apiError):
			return apiError.description
		case .noCollections:
			return L10n.NetworkError.noCollections
		case .noNfts:
			return L10n.NetworkError.noNfts
		case .noNftsByAuthorID(let authorID):
			return String(format: L10n.NetworkError.noNftsByAuthorID, authorID)
		case .noNftByID(let id):
			return String(format: L10n.NetworkError.noNftByID, id)
		case .noAuthorByID(let id):
			return String(format: L10n.NetworkError.noAuthorByID, id)
		case .brokenLikes:
			return L10n.NetworkError.brokenLikes
		case .brokenOrder:
			return L10n.NetworkError.brokenOrder
		case .noProfile:
			return L10n.NetworkError.noProfile
		case .noAuthors:
			return L10n.NetworkError.noAuthors
		case .notConnectedToInternet:
			return L10n.NetworkError.notConnectedToInternet
		}
	}

	var description: String {
		localizedDescription
	}
}
