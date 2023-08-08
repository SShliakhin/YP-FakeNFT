import Foundation

struct ProfileDTO: Model {
	let name: String?
	let avatar: String?
	let description: String?
	let website: String?
	let nfts: [String]?
	let likes: [String]?
}
