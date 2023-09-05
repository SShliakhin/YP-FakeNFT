protocol ProfileModuleFactory {
	func makeProfileViewController(viewModel: ProfileViewModel) -> Presentable
	func makeEditProfileViewController(viewModel: ProfileViewModel) -> Presentable
	func makeMyNftsViewController(viewModel: MyNftsViewModel) -> Presentable
	func makeFavoritesViewController(viewModel: FavoritesViewModel) -> Presentable

	func makeWebViewController(viewModel: WebViewModel) -> Presentable
	func makeErrorAlertVC(message: String, completion: (() -> Void)?) -> Presentable
	func makeSortAlertVC<T: CustomStringConvertible>(sortCases: [T], completion: @escaping (T) -> Void) -> Presentable
}
