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
