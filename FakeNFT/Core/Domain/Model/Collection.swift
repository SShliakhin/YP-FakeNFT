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
