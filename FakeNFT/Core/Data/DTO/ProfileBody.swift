import Foundation

struct ProfileBody: Model {
	let name: String
	let avatar: URL?
	let description: String
	let website: URL?
}

extension ProfileBody: Equatable {
	static func == (lhs: ProfileBody, rhs: ProfileBody) -> Bool {
		return lhs.name == rhs.name &&
		lhs.avatar == rhs.avatar &&
		lhs.description == rhs.description &&
		lhs.website == rhs.website
	}
}
