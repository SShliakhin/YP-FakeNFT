import Foundation

struct Collection {
	let id: String
	let name: String
	let description: String
	let cover: URL?
	let nfts: [String]
	let authorID: String

	var nftsCount: Int {
		nfts.count
	}
}

extension Collection {
	init?(from dto: CollectionDTO) {
		guard
			let id = dto.id,
			let name = dto.name
		else { return nil }
		self.id = id
		self.name = name
		self.description = dto.description ?? ""
		self.cover = URL(string: dto.cover?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
		self.nfts = dto.nfts ?? []
		self.authorID = dto.author ?? ""
	}
}
