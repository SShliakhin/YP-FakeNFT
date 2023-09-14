protocol AuthorsRepository {
	func putItems(items: [Author])
	func getItemByID(_ id: String) -> Author?
}

final class AuthorsRepositoryImp: AuthorsRepository {
	private var items: [Author] = []

	func putItems(items: [Author]) {
		self.items = items
	}
	func getItemByID(_ id: String) -> Author? {
		items.first(where: { $0.id == id })
	}
}
