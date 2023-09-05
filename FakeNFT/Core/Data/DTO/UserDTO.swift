import Foundation

struct UserDTO: Model {
	let name: String?
	let avatar: String?
	let description: String?
	let website: String?
	let nfts: [String]?
	let rating: String?
	let id: String?
}

extension UserDTO {
	func toDomainAuthor() -> Author? {
		guard let name = name, let id = id else { return nil }
		return Author(
			id: id,
			name: name,
			website: URL(string: website?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
		)
	}
}
