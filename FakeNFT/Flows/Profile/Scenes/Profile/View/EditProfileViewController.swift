import UIKit
import ProgressHUD

final class EditProfileViewController: UIViewController {
	private let viewModel: ProfileViewModel

	private var profileAvatarUrl: URL? {
		avatarView.avatarUrl
	}
	private var profileName: String = "" {
		didSet {
			guard oldValue != profileName else { return }
			if profileName.isEmpty {
				profileName = oldValue
				titleTextField.text = oldValue
			} else {
				titleTextField.text = profileName
			}
		}
	}
	private var profileDescription: String = "" {
		didSet {
			guard oldValue != profileDescription else { return }
			descriptionTextView.text = profileDescription
		}
	}
	private var profileUrl: URL? {
		didSet {
			guard oldValue != profileUrl else { return }
			urlTextField.text = profileUrl?.absoluteString
		}
	}

	// MARK: - UI Elements
	private lazy var closeButton: UIButton = makeCloseButton()
	private lazy var avatarView = AvatarView()

	private lazy var titleLabel: UILabel = makeStaticTextLabel(
		text: Theme.Profile.editTitleName
	)
	private lazy var descriptionLabel: UILabel = makeStaticTextLabel(
		text: Theme.Profile.editTitleDescription
	)
	private lazy var urlLabel: UILabel = makeStaticTextLabel(
		text: Theme.Profile.editTitleWebsite
	)

	private lazy var titleTextField: UITextField = makeTextField()
	private lazy var descriptionTextView: UITextView = makeDescriptionTextView()
	private lazy var urlTextField: UITextField = makeTextField()

	// MARK: - Inits

	init(viewModel: ProfileViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		setup()
		applyStyle()
		setConstraints()

		bind(to: viewModel)
		if let profile = viewModel.profile.value {
			// viewModel должна быть готова с прошлого экрана
			// странно повторно будет делать запрос profile
			updateItems(with: profile)
		} else {
			viewModel.viewIsReady()
		}
	}
}

// MARK: - Bind

private extension EditProfileViewController {
	func bind(to viewModel: ProfileViewModel) {
		viewModel.profile.observe(on: self) { [weak self] profile in
			guard let profile = profile else { return }
			self?.updateItems(with: profile)
		}
		viewModel.isLoading.observe(on: self) { isLoading in
			isLoading ? ProgressHUD.show() : ProgressHUD.dismiss()
		}
	}

	func updateItems(with profile: Profile) {
		avatarView.update(with: AvatarViewModel(
			url: profile.avatar,
			isUploadButtonHidden: true,
			onTapUploadImage: { [weak self] in
				self?.viewModel.didUserDo(request: .updateAvatar)
			}
		))
		profileName = profile.name
		profileDescription = profile.description
		profileUrl = profile.website
	}
}

// MARK: - UITextFieldDelegate

extension EditProfileViewController: UITextFieldDelegate {
	func textFieldDidEndEditing(_ textField: UITextField) {
		guard let text = textField.text else { return }
		let title = text.trimmingCharacters(in: .whitespacesAndNewlines)
		switch textField {
		case titleTextField:
			profileName = title
		case urlTextField:
			profileUrl = URL(string: title)
		default:
			return
		}
		updateProfile()
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}

// MARK: - UITextViewDelegate

extension EditProfileViewController: UITextViewDelegate {
	func textViewDidEndEditing(_ textView: UITextView) {
		guard let text = textView.text else { return }
		let title = text.trimmingCharacters(in: .whitespacesAndNewlines)
		profileDescription = title
		updateProfile()
	}
}

private extension EditProfileViewController {
	func updateProfile() {
		viewModel.didUserDo(request: .updateProfile(
			ProfileUpdate(
				name: profileName,
				avatar: profileAvatarUrl,
				description: profileDescription,
				website: profileUrl
			)
		))
	}
}

// MARK: - UI
private extension EditProfileViewController {
	func setup() {
		setupDismissKeyboardGesture()
		setupKeyboardHiding()
	}

	func applyStyle() {
		view.backgroundColor = Theme.color(usage: .white)
	}

	func setConstraints() {
		let vStack = makeMainVStackView()

		[
			closeButton,
			vStack
		].forEach { view.addSubview($0) }
		closeButton.makeConstraints { $0.size(Appearance.closeButtonSize) }
		closeButton.makeConstraints { make in
			[
				make.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.spacing(usage: .standard2)),
				make.topAnchor.constraint(equalTo: view.topAnchor, constant: Theme.spacing(usage: .standard2))
			]
		}
		vStack.makeEqualToSuperview(insets: .init(
			horizontal: Theme.spacing(usage: .standard2),
			vertical: Appearance.topInset
		))
	}

	func makeMainVStackView() -> UIStackView {
		let vNameStack = makeTextContainerVStackView(
			textBase: titleTextField,
			height: Appearance.nameLimitHeight,
			textLabel: titleLabel
		)
		let vDescriptionStack = makeTextContainerVStackView(
			textBase: descriptionTextView,
			height: Appearance.descriptionLimitHeight,
			textLabel: descriptionLabel
		)
		let vUrlStack = makeTextContainerVStackView(
			textBase: urlTextField,
			height: Appearance.urlLimitHeight,
			textLabel: urlLabel
		)

		let vStack = UIStackView(
			arrangedSubviews: [
				avatarView,
				vNameStack,
				vDescriptionStack,
				vUrlStack,
				UIView()
			]
		)
		vStack.axis = .vertical
		vStack.spacing = Theme.spacing(usage: .standard3)
		vStack.alignment = .center

		vNameStack.makeConstraints { make in
			[
				make.leadingAnchor.constraint(equalTo: vStack.leadingAnchor),
				make.trailingAnchor.constraint(equalTo: vStack.trailingAnchor)
			]
		}
		vDescriptionStack.makeConstraints { make in
			[
				make.leadingAnchor.constraint(equalTo: vStack.leadingAnchor),
				make.trailingAnchor.constraint(equalTo: vStack.trailingAnchor)
			]
		}
		vUrlStack.makeConstraints { make in
			[
				make.leadingAnchor.constraint(equalTo: vStack.leadingAnchor),
				make.trailingAnchor.constraint(equalTo: vStack.trailingAnchor)
			]
		}

		return vStack
	}

	func makeTextContainerVStackView(textBase: UIView, height: CGFloat, textLabel: UIView) -> UIStackView {
		let textContainer = makeTextContainer()
		textContainer.addSubview(textBase)
		textBase.makeEqualToSuperview(insets: Appearance.textInsets)
		textBase.makeConstraints {
			[$0.heightAnchor.constraint(equalToConstant: height)]
		}

		let textContainerVStackView = UIStackView(arrangedSubviews: [textLabel, textContainer])
		textContainerVStackView.axis = .vertical
		textContainerVStackView.spacing = Theme.spacing(usage: .standard)
		textLabel.makeConstraints {
			[$0.heightAnchor.constraint(equalToConstant: Appearance.labelLimitHeight)]
		}

		return textContainerVStackView
	}
}

// MARK: - UI make
private extension EditProfileViewController {
	func makeCloseButton() -> UIButton {
		let headline = UIImage.SymbolConfiguration(textStyle: .headline)
		let bold = UIImage.SymbolConfiguration(weight: .bold)
		let combined = headline.applying(bold)

		let button = UIButton(type: .custom)
		button.setImage(Theme.image(kind: .close).withConfiguration(combined), for: .normal)
		button.tintColor = Theme.color(usage: .black)
		button.event = { [weak self] in self?.viewModel.didUserDo(request: .goBack) }

		return button
	}

	func makeStaticTextLabel(text: String) -> UILabel {
		let label = UILabel()
		label.textColor = Theme.color(usage: .main)
		label.font = Theme.font(style: .title2)
		label.text = text

		return label
	}

	func makeTextField() -> UITextField {
		let textField = UITextField()

		textField.backgroundColor = .clear
		textField.textColor = Theme.color(usage: .main)
		textField.font = Theme.font(style: .body)

		textField.clearButtonMode = .whileEditing
		textField.returnKeyType = .done

		textField.delegate = self

		return textField
	}

	func makeDescriptionTextView() -> UITextView {
		let textView = UITextView()

		textView.backgroundColor = .clear
		textView.textColor = Theme.color(usage: .main)
		textView.font = Theme.font(style: .body)

		// опытным путем дошел до -5, по другому не получается(, есть идеи?
		textView.textContainerInset = .init(horizontal: -5, vertical: .zero)

		textView.delegate = self

		return textView
	}

	func makeTextContainer() -> UIView {
		let view = UIView()
		view.backgroundColor = Theme.color(usage: .lightGray)
		view.layer.cornerRadius = Theme.dimension(kind: .largeRadius)
		view.layer.masksToBounds = true

		return view
	}
}

private extension EditProfileViewController {
	enum Appearance {
		static let closeButtonSize: CGSize = .init(width: 42, height: 42)

		static let imagePlaceholder = Theme.image(kind: .imagePlaceholder)
		static let avatarSize: CGSize = .init(width: 70, height: 70)
		static let avatarCornerRadius = 35.0
		static let avatarBorderWidth = 1.0

		static let textInsets: UIEdgeInsets = .init(
			horizontal: Theme.spacing(usage: .standard2),
			vertical: 11.0
		)

		static let topInset = 80.0
		static let nameLimitHeight = 22.0
		static let descriptionLimitHeight = 110.0
		static let urlLimitHeight = 22.0
		static let labelLimitHeight = 28.0
	}
}

// MARK: Keyboard
// TODO: - претендент на вынес в библиотеку - как расширение UIViewController

extension EditProfileViewController {
	func setupDismissKeyboardGesture() {
		let dismissKeyboardTap = UITapGestureRecognizer(
			target: self,
			action: #selector(viewTapped(_: ))
		)
		view.addGestureRecognizer(dismissKeyboardTap)
	}

	func setupKeyboardHiding() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillShow),
			name: UIResponder.keyboardWillShowNotification,
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillHide),
			name: UIResponder.keyboardWillHideNotification,
			object: nil
		)
	}

	@objc func viewTapped(_ recognizer: UITapGestureRecognizer) {
		view.endEditing(true) // resign first responder
	}

	@objc func keyboardWillShow(sender: NSNotification) {
		guard let userInfo = sender.userInfo,
			  let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
			  UIResponder.currentFirst() is UITextField ||
				UIResponder.currentFirst() is UITextView,
			  let responderView = UIResponder.currentFirst() as? UIView
		else { return }

		let keyboardTopY = keyboardFrame.cgRectValue.origin.y
		let convertedResponderViewFrame = view.convert(
			responderView.frame,
			from: responderView.superview
		)
		let textBoxY = convertedResponderViewFrame.origin.y

		// почему то TextView не попадает под этот критерий
		// убрал проверку, чтобы VC всегда подымался
		// let responderViewBottomY = textBoxY + convertedResponderViewFrame.size.height
		// if responderViewBottomY > keyboardTopY {
			let newFrameY = (textBoxY - keyboardTopY / 2) * -1
			view.frame.origin.y = newFrameY
		// }
	}

	@objc func keyboardWillHide(notification: NSNotification) {
		view.frame.origin.y = 0
	}
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct EditProfileViewControllerProvider: PreviewProvider {
	static var previews: some View {
		let dep = DefaultProfileViewModel.Dependencies(
			getProfile: ProfileUseCaseProvider.instance.getProfile,
			putProfile: ProfileUseCaseProvider.instance.putProfile
		)
		let viewModel: ProfileViewModel = DefaultProfileViewModel(dep: dep)
		let editProfileViewController = EditProfileViewController(viewModel: viewModel)
		editProfileViewController.updateItems(with: Profile(
			name: "Joaquin Phoenix", // Студентус Практикумус
			avatar: URL(string: "https://code.s3.yandex.net/landings-v2-ios-developer/space.PNG"),
			// swiftlint:disable:next line_length
			description: "Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100+ NFT, и еще больше — на моём сайте. Открыт к коллаборациям.",
			website: URL(string: "Joaquin_Phoenix.com"),
			nfts: [],
			likes: []
		))

		return editProfileViewController.preview()
	}
}
#endif

// TODO: - претендент на вынес в библиотеку

extension UIResponder {

	private enum Static {
		static weak var responder: UIResponder?
	}

	/// Finds the current first responder
	/// - Returns: the current UIResponder if it exists
	static func currentFirst() -> UIResponder? {
		Static.responder = nil
		UIApplication.shared.sendAction(#selector(UIResponder._trap), to: nil, from: nil, for: nil)
		return Static.responder
	}

	@objc private func _trap() {
		Static.responder = self
	}
}
