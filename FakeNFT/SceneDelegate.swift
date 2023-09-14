import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	private let appFactory = AppDIContainer()
	private var appCoordinator: Coordinator?
	var window: UIWindow?

	func scene(
		_ scene: UIScene,
		willConnectTo _: UISceneSession,
		options _: UIScene.ConnectionOptions
	) {
		guard let windowScene = (scene as? UIWindowScene) else { return }

		AppAppearance.setupAppearance()

		let (window, coordinator) = appFactory
			.makeKeyWindowWithCoordinator(scene: windowScene)

		self.window = window
		self.appCoordinator = coordinator

		 coordinator.start()
	}
}
