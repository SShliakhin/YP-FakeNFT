protocol AuthModuleFactory {
	func makeAuthViewController(viewModel: AuthViewModel) -> Presentable
}
