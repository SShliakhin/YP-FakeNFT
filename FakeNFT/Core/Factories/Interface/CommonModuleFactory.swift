protocol CommonModuleFactory {
	func makeSplashViewController() -> Presentable
	func makeWebViewController(viewModel: WebViewModel) -> Presentable
	func makeErrorAlertVC(message: String, completion: (() -> Void)?) -> Presentable
	func makeSortAlertVC<T: CustomStringConvertible>(sortCases: [T], completion: @escaping (T) -> Void) -> Presentable
}
