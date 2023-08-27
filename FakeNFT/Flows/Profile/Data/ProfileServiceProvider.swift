import Foundation

final class ProfileServiceProvider {
	private let session = URLSession(configuration: .default)
	lazy var apiClient: APIClient = {
		APIClient(session: session)
	}()
	lazy var profileRepository: ProfileRepository = {
		ProfileRepositoryImp()
	}()
}
