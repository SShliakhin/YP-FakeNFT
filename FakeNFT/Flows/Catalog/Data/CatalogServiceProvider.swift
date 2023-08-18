import Foundation

final class CatalogServiceProvider {
	private let session = URLSession(configuration: .default)
	lazy var apiClient: APIClient = {
		APIClient(session: session)
	}()
}
