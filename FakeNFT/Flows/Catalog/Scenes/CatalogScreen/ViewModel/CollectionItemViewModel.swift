import Foundation

struct CollectionItemViewModel: CustomStringConvertible {
	let id: String
	let title: String
	let nftsCount: Int
	let cover: URL?

	var description: String {
		"\(title) (\(nftsCount))"
	}
}

extension CollectionItemViewModel {
	init(collection: Collection) {
		id = collection.id
		title = collection.name
		nftsCount = collection.nftsCount
		cover = collection.cover
	}
}
