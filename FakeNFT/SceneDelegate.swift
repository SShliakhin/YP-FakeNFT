import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?

	func scene(
		_ scene: UIScene,
		willConnectTo _: UISceneSession,
		options _: UIScene.ConnectionOptions
	) {
		guard let windowScene = (scene as? UIWindowScene) else { return }

		AppAppearance.setupAppearance()

		window = UIWindow(windowScene: windowScene)
		window?.rootViewController = makeRootViewController()
		window?.makeKeyAndVisible()
	}

	func makeRootViewController() -> MainTabBarController {
		MainTabBarController()
	}
}
