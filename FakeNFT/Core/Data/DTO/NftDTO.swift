import Foundation

struct NftDTO: Model {
	let name: String?
	let images: [String]?
	let rating: Int?
	let description: String?
	let price: Double?
	let author: String?
	let id: String?
}

extension NftDTO {
	func toDomain() -> Nft? {
		guard let name = name, let id = id else { return nil }
		return Nft(
			id: id,
			name: name,
			description: description ?? "",
			rating: rating ?? 0,
			images: images?
				.compactMap {
					URL(string: $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
				} ?? [],
			price: price ?? 0,
			authorID: author ?? ""
		)
	}
}
