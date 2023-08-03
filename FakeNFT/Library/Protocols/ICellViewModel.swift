import UIKit

protocol ICellViewAnyModel {
	static var cellAnyType: UIView.Type { get }
	func setupAny(cell: UIView)
}

protocol ICellViewModel: ICellViewAnyModel {
	associatedtype CellType: UIView
	func setup(cell: CellType)
}

extension ICellViewModel {
	static var cellAnyType: UIView.Type {
		return CellType.self
	}

	func setupAny(cell: UIView) {
		if let cell = cell as? CellType {
			setup(cell: cell)
		} else {
			assertionFailure("Wrong usage")
		}
	}
}
