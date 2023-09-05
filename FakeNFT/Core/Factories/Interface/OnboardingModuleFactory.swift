protocol OnboardingModuleFactory {
	func makeOnboardingViewController(viewModel: OnboardingViewModel) -> Presentable
}
