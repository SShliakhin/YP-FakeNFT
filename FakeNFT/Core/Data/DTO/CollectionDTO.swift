import Foundation

struct CollectionDTO: Model {
	let name: String?
	let cover: String?
	let nfts: [String]?
	let description: String?
	let author: String?
	let id: String?
}

extension CollectionDTO {
	func toDomain() -> Collection? {
		guard let name = name, let id = id else { return nil }
		return Collection(
			id: id,
			name: name,
			description: description ?? "",
			cover: URL(string: cover?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""),
			nfts: nfts ?? [],
			authorID: author ?? ""
		)
	}
}
