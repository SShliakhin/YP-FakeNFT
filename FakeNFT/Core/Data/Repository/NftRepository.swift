protocol NftRepository {
	func getNftByID(_ nftID: String) -> Nft?
	func getNftByIDs(_ nftIDs: [String]) -> [Nft]?
	func getNftByAuthorID(_ authorID: String) -> [Nft]?
	func addNft(_ nft: Nft)
	func addNfts(_ nfts: [Nft])
	func addNftsWithAuthorID(_ nfts: [Nft], authorID: String)
}

final class NftRepositoryImp: NftRepository {
	private var nfts: [Nft] = []
	private var authorsIDs: [String] = []

	private var nftsEmpty: Bool {
		nfts.isEmpty
	}

	func getNftByID(_ nftID: String) -> Nft? {
		nfts.first(where: { $0.id == nftID })
	}

	func getNftByIDs(_ nftIDs: [String]) -> [Nft]? {
		guard !nftIDs.isEmpty else { return nil }

		let filteredNfts = nfts.filter { nftIDs.contains($0.id) }
		if filteredNfts.count == nftIDs.count {
			return filteredNfts
		}

		return nil
	}

	func getNftByAuthorID(_ authorID: String) -> [Nft]? {
		guard authorsIDs.contains(authorID) else { return nil }
		return nfts.filter { $0.authorID == authorID }
	}

	func addNft(_ nft: Nft) {
		guard !nfts.contains(where: { $0.id == nft.id }) else { return }
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

	func addNftsWithAuthorID(_ nfts: [Nft], authorID: String) {
		guard !authorsIDs.contains(authorID) else { return }
		authorsIDs.append(authorID)
		addNfts(nfts)
	}
}
