import Foundation
import UIKit

enum ProfileSection: CustomStringConvertible {
	case myNFTs(Int)
	case favoritesNFTS(Int)
	case about

	var description: String {
		switch self {
		case .myNFTs(let count):
			return String(format: Theme.Profile.myNftsCall, count)
		case .favoritesNFTS(let count):
			return String(format: Theme.Profile.favoritesCall, count)
		case .about:
			return Theme.Profile.aboutCall
		}
	}
}

private extension ProfileSection {
	enum Appearance {
		static let myNTFsTitle = "Мои NFT (%d)"
		static let favoritesTitle = "Избранные NFT (%d)"
		static let aboutTitle = "О разработчике"
	}
}

enum ProfileEvents {
	case showErrorAlert(String, Bool)
	case selectEditProfile
	case selectMyNfts(Profile)
	case selectFavorites(Profile)
	case selectAbout(URL?)
}

enum ProfileRequest {
	case selectItemAtIndex(Int)
	case retryAction
	case editProfile
}

protocol ProfileViewModelInput: AnyObject {
	var didSendEventClosure: ((ProfileEvents) -> Void)? { get set }

	func viewIsReady()
	func didUserDo(request: ProfileRequest)
}

protocol ProfileViewModelOutput: AnyObject {
	var profile: Observable<Profile?> { get }
	var items: Observable<[ProfileSection]> { get }
	var isLoading: Observable<Bool> { get }
	var numberOfItems: Int { get }
	var cellModels: [ICellViewAnyModel.Type] { get }

	func cellModelAtIndex(_ index: Int) -> ICellViewAnyModel
}

typealias ProfileViewModel = (
	ProfileViewModelInput &
	ProfileViewModelOutput
)

final class DefaultProfileViewModel: ProfileViewModel {
	struct Dependencies {
		let getProfile: GetProfileUseCase
		let myNFTsVM: MyNFTsViewModel
		let favoritesVM: FavoritesViewModel
	}
	private let dependencies: Dependencies
	private var retryAction: (() -> Void)?

	// MARK: - INPUT
	var didSendEventClosure: ((ProfileEvents) -> Void)?

	// MARK: - OUTPUT
	var profile: Observable<Profile?> = Observable(nil)
	var items: Observable<[ProfileSection]> = Observable([])
	var isLoading: Observable<Bool> = Observable(false)

	var numberOfItems: Int {
		items.value.count
	}
	var cellModels: [ICellViewAnyModel.Type] = [ProfileItemCellModel.self]

	// MARK: - Inits

	init(dep: Dependencies) {
		dependencies = dep
	}
}

// MARK: - OUTPUT

extension DefaultProfileViewModel {
	func cellModelAtIndex(_ index: Int) -> ICellViewAnyModel {
		let item = items.value[index]

		return ProfileItemCellModel(
			description: item.description
		)
	}
}

// MARK: - INPUT. View event methods

extension DefaultProfileViewModel {
	func viewIsReady() {
		isLoading.value = true

		dependencies.getProfile.invoke { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let profile):
				self.profile.value = profile
				self.makeItems(for: profile)
			case .failure(let error):
				self.retryAction = { self.viewIsReady() }
				self.didSendEventClosure?(.showErrorAlert(error.description, true))
			}

			self.isLoading.value = false
		}
	}

	func didUserDo(request: ProfileRequest) {
		switch request {
		case .retryAction:
			retryAction?()
		case .selectItemAtIndex(let index):
			let item = items.value[index]
			switch item {
			case .myNFTs:
				guard let profile = profile.value else { return }
				didSendEventClosure?(.selectMyNfts(profile))
			case .favoritesNFTS:
				guard let profile = profile.value else { return }
				didSendEventClosure?(.selectFavorites(profile))
			case .about:
				didSendEventClosure?(.selectAbout(profile.value?.website))
			}
		case .editProfile:
			didSendEventClosure?(.selectEditProfile)
		}
	}
}

private extension DefaultProfileViewModel {
	func makeItems(for profile: Profile) {
		items.value = [
			ProfileSection.myNFTs(profile.nftsCount),
			ProfileSection.favoritesNFTS(profile.likesCount),
			ProfileSection.about
		]
	}
}
