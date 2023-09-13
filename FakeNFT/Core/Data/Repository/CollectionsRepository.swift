protocol CollectionsRepository {
	var items: [Collection] { get }

	func putItems(items: [Collection])
	func getItemByID(_ id: String) -> Collection?
}

final class CollectionsRepositoryImp: CollectionsRepository {
	var items: [Collection] = []

	func putItems(items: [Collection]) {
		self.items = items
	}
	func getItemByID(_ id: String) -> Collection? {
		items.first(where: { $0.id == id })
	}
}
