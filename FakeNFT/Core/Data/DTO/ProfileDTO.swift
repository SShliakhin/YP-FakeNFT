import Foundation

struct ProfileDTO: Model {
	let name: String?
	let avatar: String?
	let description: String?
	let website: String?
	let nfts: [String]?
	let likes: [String]?
}

extension ProfileDTO {
	func toDomain() -> Profile? {
		guard let name = name else { return nil }
		return Profile(
			name: name,
			avatar: URL(string: avatar?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""),
			description: description ?? "",
			website: URL(string: website?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""),
			nfts: nfts ?? [],
			likes: likes ?? []
		)
	}
}
