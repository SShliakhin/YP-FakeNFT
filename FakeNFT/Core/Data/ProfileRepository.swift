import Foundation

struct ProfileUpdate: Model {
	let name: String
	let avatar: URL?
	let description: String
	let website: URL?
}

extension ProfileUpdate: Equatable {
	static func == (lhs: ProfileUpdate, rhs: ProfileUpdate) -> Bool {
		return lhs.name == rhs.name &&
		lhs.avatar == rhs.avatar &&
		lhs.description == rhs.description &&
		lhs.website == rhs.website
	}
}

protocol ProfileRepository {
	var profile: Observable<ProfileUpdate> { get set }
}

final class ProfileRepositoryImp: ProfileRepository {
	var profile: Observable<ProfileUpdate> = Observable(
		ProfileUpdate(name: "", avatar: nil, description: "", website: nil)
	)
}
