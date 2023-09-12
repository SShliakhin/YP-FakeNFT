import Foundation

enum ProfileSection: CustomStringConvertible {
	case myNFTs(Int?)
	case favoritesNFTS(Int?)
	case search
	case about

	var description: String {
		switch self {
		case .myNFTs(let count):
			return String(format: L10n.Profile.myNftsCall, count ?? 0)
		case .favoritesNFTS(let count):
			return String(format: L10n.Profile.favoritesCall, count ?? 0)
		case .search:
			return L10n.Profile.searchNftsCall
		case .about:
			return L10n.Profile.aboutCall
		}
	}
}

enum ProfileEvents {
	case showErrorAlert(String, Bool)
	case selectEditProfile
	case selectMyNfts
	case selectFavorites
	case selectSearchNfts
	case selectAbout(URL?)
	case close
}

enum ProfileRequest {
	case selectItemAtIndex(Int)
	case retryAction
	case editProfile
	case goBack
	case updateProfile(ProfileUpdate)
	case updateAvatar
}

protocol ProfileViewModelInput: AnyObject {
	var didSendEventClosure: ((ProfileEvents) -> Void)? { get set }

	func viewIsReady()
	func didUserDo(request: ProfileRequest)
}

protocol ProfileViewModelOutput: AnyObject {
	var profile: Observable<ProfileUpdate> { get }
	var items: Observable<[ProfileSection]> { get }
	var isLoading: Observable<Bool> { get }
	var numberOfItems: Int { get }
	var cellModels: [ICellViewAnyModel.Type] { get }

	var editTitleName: String { get }
	var editTitleDescription: String { get }
	var editTitleWebsite: String { get }

	func cellModelAtIndex(_ index: Int) -> ICellViewAnyModel
}

typealias ProfileViewModel = (
	ProfileViewModelInput &
	ProfileViewModelOutput
)

final class DefaultProfileViewModel: ProfileViewModel {
	struct Dependencies {
		let getProfile: GetProfileUseCase
		let putProfile: PutProfileUseCase
		let profileRepository: ProfileRepository
		let likesIDsRepository: NftsIDsRepository
		let myNftsIDsRepository: NftsIDsRepository
	}
	private let dependencies: Dependencies
	private var retryAction: (() -> Void)?
	private var mockAvatarUrls: [URL?] = Appearance.mockUrls

	// MARK: - INPUT
	var didSendEventClosure: ((ProfileEvents) -> Void)?

	// MARK: - OUTPUT
	var profile: Observable<ProfileUpdate> = Observable(
		ProfileUpdate(name: "", avatar: nil, description: "", website: nil)
	)
	var items: Observable<[ProfileSection]> = Observable([])
	var isLoading: Observable<Bool> = Observable(false)

	var numberOfItems: Int {
		items.value.count
	}
	var cellModels: [ICellViewAnyModel.Type] = [ProfileItemCellModel.self]

	let editTitleName: String = L10n.Profile.editTitleName
	let editTitleDescription: String = L10n.Profile.editTitleDescription
	let editTitleWebsite: String = L10n.Profile.editTitleWebsite

	// MARK: - Inits

	init(dep: Dependencies) {
		dependencies = dep

		self.bind(to: dep.profileRepository)
		self.bind(to: dep.likesIDsRepository)
		self.bind(to: dep.myNftsIDsRepository)
	}
}

// MARK: - Bind

private extension DefaultProfileViewModel {
	func bind(to repository: ProfileRepository) {
		repository.profile.observe(on: self) { [weak self] profile in
			self?.profile.value = profile
		}
	}
	func bind(to repository: NftsIDsRepository) {
		repository.items.observe(on: self) { [weak self] _ in
			self?.makeItems()
		}
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
		profile.value = dependencies.profileRepository.profile.value
	}

	func didUserDo(request: ProfileRequest) {
		switch request {
		case .retryAction:
			retryAction?()
		case .selectItemAtIndex(let index):
			let item = items.value[index]
			switch item {
			case .myNFTs:
				didSendEventClosure?(.selectMyNfts)
			case .favoritesNFTS:
				didSendEventClosure?(.selectFavorites)
			case .search:
				didSendEventClosure?(.selectSearchNfts)
			case .about:
				didSendEventClosure?(.selectAbout(profile.value.website))
			}
		case .editProfile:
			didSendEventClosure?(.selectEditProfile)
		case .goBack:
			didSendEventClosure?(.close)
		case .updateProfile(let updateProfile):
			self.updateProfile(profile.value, with: updateProfile)
		case .updateAvatar:
			self.updateAvatar()
		}
	}
}

private extension DefaultProfileViewModel {
	func makeItems() {
		items.value = [
			ProfileSection.myNFTs(dependencies.myNftsIDsRepository.numberOfItems),
			ProfileSection.favoritesNFTS(dependencies.likesIDsRepository.numberOfItems),
			ProfileSection.search,
			ProfileSection.about
		]
	}

	func updateProfile(_ oldProfile: ProfileUpdate, with newProfile: ProfileUpdate) {
		guard oldProfile != newProfile else { return }

		self.isLoading.value = true

		dependencies.putProfile.invoke(body: newProfile) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success:
				self.dependencies.profileRepository.profile.value = newProfile
			case .failure(let error):
				self.retryAction = { self.didUserDo(request: .updateProfile(newProfile)) }
				self.didSendEventClosure?(.showErrorAlert(error.description, true))
			}

			self.isLoading.value = false
		}
	}

	func updateAvatar() {
		let currentAvatar = profile.value.avatar
		let newAvatar = mockAvatarUrls.filter { $0 != currentAvatar }
			.compactMap { $0 }
			.randomElement()
		if !mockAvatarUrls.contains(currentAvatar) {
			mockAvatarUrls.append(currentAvatar)
		}
		let newProfile = ProfileUpdate(
			name: profile.value.name,
			avatar: newAvatar,
			description: profile.value.description,
			website: profile.value.website
		)
		updateProfile(profile.value, with: newProfile)
	}
}

private extension DefaultProfileViewModel {
	enum Appearance {
		static let mockUrls: [URL?] = [
			URL(string: "https://avatars.mds.yandex.net/get-kinopoisk-image/1629390/382f1545-aa14-4a7f-8f89-a1afb4656923/3840x"),
			URL(string: "https://avatars.mds.yandex.net/get-kinopoisk-image/1704946/6a1e205b-1fa4-480e-a57d-a14415362b96/3840x"),
			URL(string: "https://code.s3.yandex.net/landings-v2-ios-developer/space.PNG")
		]
	}
}
