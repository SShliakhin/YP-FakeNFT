final class ShoppingCartCoordinator: BaseCoordinator {
	private let factory: ShoppingCartModuleFactory
	private let router: Router

	init(router: Router, factory: ShoppingCartModuleFactory) {
		self.router = router
		self.factory = factory
	}

	override func start() {
		showShoppingCartModule()
	}

	deinit {
		print("ShoppingCartCoordinator deinit")
	}
}

// MARK: - show Modules
private extension ShoppingCartCoordinator {
	func showShoppingCartModule() {
		let module = factory.makeShoppinCartViewController(viewModel: DefaultShoppingCartViewModel())
		router.setRootModule(module)
	}
}

protocol ShoppingCartFlowDIContainer {
	func makeShoppingCartViewModel() -> ShoppingCartViewModel
}

final class ShoppingCartFlowDIContainerImp: ShoppingCartFlowDIContainer {
	func makeShoppingCartViewModel() -> ShoppingCartViewModel {
		DefaultShoppingCartViewModel()
	}
}

protocol ShoppingCartViewModel {}
final class DefaultShoppingCartViewModel: ShoppingCartViewModel {}
