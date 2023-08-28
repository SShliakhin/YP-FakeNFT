import Foundation

struct Profile {
	let name: String
	let avatar: URL?
	let description: String
	let website: URL?
	let nfts: [String]
	let likes: [String]

	var nftsCount: Int {
		nfts.count
	}
	var likesCount: Int {
		likes.count
	}
}

extension Profile {
	init?(from dto: ProfileDTO) {
		guard
			let name = dto.name
		else { return nil }
		self.name = name
		self.avatar = URL(string: dto.avatar?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
		self.description = dto.description ?? ""
		self.website = URL(string: dto.website?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
		self.nfts = dto.nfts ?? []
		self.likes = dto.likes ?? []
	}
}
