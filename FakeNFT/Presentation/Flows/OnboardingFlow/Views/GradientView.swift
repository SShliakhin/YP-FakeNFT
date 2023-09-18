import UIKit

final class GradientView: UIView {

	private lazy var gradientLayer = CAGradientLayer()

	override init(frame: CGRect) {
		super.init(frame: frame)
		layer.insertSublayer(gradientLayer, at: 0)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSublayers(of layer: CALayer) {
		super.layoutSublayers(of: layer)
		gradientLayer.frame = bounds
	}

	@discardableResult
	func update(with layer: CAGradientLayer) -> Self {
		gradientLayer.colors = layer.colors
		gradientLayer.locations = layer.locations
		gradientLayer.startPoint = layer.startPoint
		gradientLayer.endPoint = layer.endPoint

		return self
	}
}

extension GradientView {
	static var OnboardingPageLayer: CAGradientLayer {
		let layer = CAGradientLayer()
		layer.colors = [
			Theme.color(usage: .allDayBlack).cgColor,
			Theme.color(usage: .allDayBlack).withAlphaComponent(0).cgColor
		]
		layer.startPoint = CGPoint(x: 1, y: 0)
		layer.endPoint = CGPoint(x: 1, y: 1)

		return layer
	}
}
