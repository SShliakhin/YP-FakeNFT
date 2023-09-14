import Foundation

struct Nft {
	let id: String
	let name: String
	let description: String
	let rating: Int
	let images: [URL]
	let price: Double
	let authorID: String

	var cover: URL? {
		images.first
	}
}
