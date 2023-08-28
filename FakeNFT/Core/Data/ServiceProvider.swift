import Foundation

final class ServiceProvider {
	private let session = URLSession(configuration: .default)
	lazy var apiClient: APIClient = {
		APIClient(session: session)
	}()
	lazy var profileRepository: ProfileRepository = {
		ProfileRepositoryImp()
	}()
}
