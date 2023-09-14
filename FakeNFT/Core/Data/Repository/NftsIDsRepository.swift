protocol NftsIDsRepository {
	var items: Observable<[String]> { get }
	var numberOfItems: Int { get }
	var isEmpty: Bool { get }

	func putItems(nftIDs: [String])
	func hasItemByID(_ nftID: String) -> Bool
}

extension NftsIDsRepository {
	var numberOfItems: Int { items.value.count }
	var isEmpty: Bool { items.value.isEmpty }

	func putItems(nftIDs: [String]) {
		items.value = nftIDs
	}
	func hasItemByID(_ nftID: String) -> Bool {
		items.value.contains(nftID)
	}
}

final class LikesIDsRepository: NftsIDsRepository {
	var items: Observable<[String]> = Observable([])
}

final class MyNftsIDsRepository: NftsIDsRepository {
	var items: Observable<[String]> = Observable([])
}

final class OrderIDsRepository: NftsIDsRepository {
	var items: Observable<[String]> = Observable([])
}
