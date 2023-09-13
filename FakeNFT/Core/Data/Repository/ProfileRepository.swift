protocol ProfileRepository {
	var profile: Observable<ProfileBody> { get set }
}

final class ProfileRepositoryImp: ProfileRepository {
	var profile: Observable<ProfileBody> = Observable(
		ProfileBody(name: "", avatar: nil, description: "", website: nil)
	)
}
