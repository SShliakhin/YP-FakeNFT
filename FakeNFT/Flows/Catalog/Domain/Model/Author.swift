import Foundation

struct Author {
	let id: String
	let name: String
	let website: URL?
}

extension Author {
	init?(from dto: UserDTO) {
		guard
			let id = dto.id,
			let name = dto.name
		else { return nil }
		self.id = id
		self.name = name
		self.website = URL(string: dto.website?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
	}
}
