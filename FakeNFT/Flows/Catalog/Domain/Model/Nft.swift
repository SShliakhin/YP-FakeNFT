import Foundation

struct Nft {
	let id: String
	let name: String
	let description: String
	let rating: Int
	let images: [URL]
	let price: Double

	var cover: URL? {
		images.first
	}
}

extension Nft {
	init?(from dto: NftDTO) {
		guard
			let id = dto.id,
			let name = dto.name
		else { return nil }
		self.id = id
		self.name = name
		self.description = dto.description ?? ""
		self.rating = dto.rating ?? 0
		self.images = dto.images?
			.compactMap { URL(string: $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
			} ?? []
		self.price = dto.price ?? 0
	}
}
