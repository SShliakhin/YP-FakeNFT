import Foundation

private enum LaunchInstructor {
	case auth, main, onboarding

	static func configureByContext(_ context: AppContextOut) -> LaunchInstructor {
		if context.isFirstStart { return .onboarding }

		if
			let validAuthDate = Calendar.current.date(
				byAdding: .day, value: 1, to: context.authDate
			),
			validAuthDate > Date()
		{ return .main }

		return .auth
	}
}

final class AppCoordinator: BaseCoordinator {
	private let coordinatorFactory: CoordinatorFactory
	private let router: Router
	private let appContext: AppContext
	private let container: AppDIContainer

	private var isDataLoaded = false

	private var instructor: LaunchInstructor {
		return LaunchInstructor.configureByContext(appContext)
	}

	init(
		coordinatorFactory: CoordinatorFactory,
		router: Router,
		appContext: AppContext,
		container: AppDIContainer
	) {
		self.coordinatorFactory = coordinatorFactory
		self.router = router
		self.appContext = appContext
		self.container = container

		appContext.reset()
	}

	override func start() {
		if !isDataLoaded {
			runStarFlow()
			return
		}

		switch instructor {
		case .onboarding:
			runOnboardingFlow()
		case .auth:
			runAuthFlow()
		case .main:
			runMainFlow()
		}
	}
}

private extension AppCoordinator {
	func runStarFlow() {
		let coordinator = coordinatorFactory.makeStartCoordinator(
			router: router,
			container: container
		)
		coordinator.finishFlow = { [weak self, weak coordinator] in
			guard let self = self else { return }
			self.isDataLoaded = true
			self.start()
			self.removeDependency(coordinator)
		}
		addDependency(coordinator)
		coordinator.start()
	}

	func runOnboardingFlow() {
		let coordinator = coordinatorFactory.makeOnboardingCoordinator(
			router: router,
			container: container
		)
		coordinator.finishFlow = { [weak self, weak coordinator] in
			guard let self = self else { return }
			self.appContext.setFirstStart()
			self.start()
			self.removeDependency(coordinator)
		}
		addDependency(coordinator)
		coordinator.start()
	}

	func runAuthFlow() {
		let coordinator = coordinatorFactory.makeAuthCoordinator(router: router)
		coordinator.finishFlow = { [weak self, weak coordinator] in
			guard let self = self else { return }
			self.appContext.setAuthDate()
			self.start()
			self.removeDependency(coordinator)
		}
		addDependency(coordinator)
		coordinator.start()
	}

	func runMainFlow() {
		let (coordinator, module) = coordinatorFactory.makeTabbarCoordinator(container: container)
		addDependency(coordinator)
		router.setRootModule(module, hideBar: true)
		coordinator.start()
	}
}
