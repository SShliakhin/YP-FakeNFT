import Foundation

struct ProfileUpdate {
	let name: String
	let avatar: URL?
	let description: String
	let website: URL?
}

enum ProfileSection: CustomStringConvertible {
	case myNFTs(Int?)
	case favoritesNFTS(Int?)
	case about

	var description: String {
		switch self {
		case .myNFTs(let count):
			return String(format: Theme.Profile.myNftsCall, count ?? 0)
		case .favoritesNFTS(let count):
			return String(format: Theme.Profile.favoritesCall, count ?? 0)
		case .about:
			return Theme.Profile.aboutCall
		}
	}
}

enum ProfileEvents {
	case showErrorAlert(String, Bool)
	case selectEditProfile
	case selectMyNfts
	case selectFavorites
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
		let putProfile: PutProfileUseCase
		let profileRepository: ProfileRepository
	}
	private let dependencies: Dependencies
	private var retryAction: (() -> Void)?
	private var mockAvatarUrls: [URL?] = Appearance.mockUrls

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

		self.bind(to: dep.profileRepository)
	}
}

// MARK: - Bind

private extension DefaultProfileViewModel {
	func bind(to repository: ProfileRepository) {
		repository.profile.observe(on: self) { [weak self] profile in
			guard let self = self else { return }
			self.profile.value = profile
			self.makeItems()
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
		isLoading.value = true

		dependencies.getProfile.invoke { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let profile):
				self.profile.value = profile
				self.makeItems()
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
				didSendEventClosure?(.selectMyNfts)
			case .favoritesNFTS:
				didSendEventClosure?(.selectFavorites)
			case .about:
				didSendEventClosure?(.selectAbout(profile.value?.website))
			}
		case .editProfile:
			didSendEventClosure?(.selectEditProfile)
		case .goBack:
			didSendEventClosure?(.close)
		case .updateProfile(let updateProfile):
			guard let profile = profile.value else { return }
			self.updateProfile(profile, with: updateProfile)
		case .updateAvatar:
			self.updateAvatar()
		}
	}
}

private extension DefaultProfileViewModel {
	func makeItems() {
		items.value = [
			ProfileSection.myNFTs(profile.value?.nftsCount),
			ProfileSection.favoritesNFTS(profile.value?.likesCount),
			ProfileSection.about
		]
	}

	func updateProfile(_ oldProfile: Profile, with newProfile: ProfileUpdate) {
		guard
			oldProfile.name != newProfile.name ||
				oldProfile.avatar != newProfile.avatar ||
				oldProfile.description != newProfile.description ||
				oldProfile.website != newProfile.website
		else { return }

		self.isLoading.value = true
		let profile = Profile(
			name: newProfile.name,
			avatar: newProfile.avatar,
			description: newProfile.description,
			website: newProfile.website,
			nfts: oldProfile.nfts,
			likes: oldProfile.likes
		)
		dependencies.putProfile.invoke(profile: profile) { result in
			switch result {
			case .success(let profile):
				self.profile.value = profile
			case .failure(let error):
				self.retryAction = { self.didUserDo(request: .updateProfile(newProfile)) }
				self.didSendEventClosure?(.showErrorAlert(error.description, true))
			}

			self.isLoading.value = false
		}
	}

	func updateAvatar() {
		guard let profile = profile.value else { return }
		let currentAvatar = profile.avatar
		let newAvatar = mockAvatarUrls.filter { $0 != currentAvatar }
			.compactMap { $0 }
			.randomElement()
		if !mockAvatarUrls.contains(currentAvatar) {
			mockAvatarUrls.append(currentAvatar)
		}
		let newProfile = ProfileUpdate(
			name: profile.name,
			avatar: newAvatar,
			description: profile.description,
			website: profile.website
		)
		updateProfile(profile, with: newProfile)
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
