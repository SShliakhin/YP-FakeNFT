protocol ProfileRepository {
	var profile: Observable<Profile?> { get set }
	var likes: Observable<[String]> { get set }
	var myNfts: Observable<[String]> { get set }

	var profileLikes: [String] { get }
	var profileMyNtfs: [String] { get }

	func getNftByID(_ nftID: String) -> Nft?
	func getNftByIDs(_ nftIDs: [String]) -> [Nft]?
	func addNft(_ nft: Nft)
	func addNfts(_ nfts: [Nft])

	func getAuthorByID(_ authorID: String) -> Author?
	func getAuthorsByIDs(_ authorsIDs: [String]) -> [Author]?
	func addAuthor(_ author: Author)
	func addAuthors(_ authors: [Author])
}

final class ProfileRepositoryImp: ProfileRepository {
	var profile: Observable<Profile?> = Observable(nil)
	var likes: Observable<[String]> = Observable([])
	var myNfts: Observable<[String]> = Observable([])

	var profileLikes: [String] {
		guard let profile = profile.value else {
			return []
		}
		return profile.likes
	}

	var profileMyNtfs: [String] {
		guard let profile = profile.value else {
			return []
		}
		return profile.nfts
	}

	private var nfts: [Nft] = []
	private var authors: [Author] = []

	// MARK: - NTFs

	private var nftsEmpty: Bool {
		nfts.isEmpty
	}

	private var authorsEmpty: Bool {
		authors.isEmpty
	}

	func getNftByID(_ nftID: String) -> Nft? {
		nfts.first(where: { $0.id == nftID })
	}

	func getNftByIDs(_ nftIDs: [String]) -> [Nft]? {
		guard !nftIDs.isEmpty else { return [] }

		let filteredNfts = nfts.filter { nftIDs.contains($0.id) }
		if filteredNfts.count == nftIDs.count {
			return filteredNfts
		}

		return nil
	}

	func addNft(_ nft: Nft) {
		nfts.append(nft)
	}

	func addNfts(_ nfts: [Nft]) {
		if nftsEmpty {
			self.nfts = nfts
			return
		}

		let nftIDs = nfts.map { $0.id }
		let newNfts = self.nfts.filter { !nftIDs.contains($0.id) } + nfts
		self.nfts = newNfts
	}

	// MARK: - Authors

	func getAuthorByID(_ authorID: String) -> Author? {
		authors.first(where: { $0.id == authorID })
	}

	func getAuthorsByIDs(_ authorsIDs: [String]) -> [Author]? {
		guard !authorsIDs.isEmpty else { return [] }

		let filteredAuthors = authors.filter { authorsIDs.contains($0.id) }
		if filteredAuthors.count == authorsIDs.count {
			return filteredAuthors
		}

		return nil
	}

	func addAuthor(_ author: Author) {
		authors.append(author)
	}

	func addAuthors(_ authors: [Author]) {
		if authorsEmpty {
			self.authors = authors
			return
		}

		let authorsIDs = authors.map { $0.id }
		let newAuthors = self.authors.filter { !authorsIDs.contains($0.id) } + authors
		self.authors = newAuthors
	}
}
