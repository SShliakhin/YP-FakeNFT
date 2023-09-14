import UIKit

extension UICollectionView {

	/// Метод для создания переиспользуемой ячейки
	/// - Parameters:
	///   - model: Модель данных
	///   - indexPath: Индекс ячейки
	/// - Returns: Сконфигурированную ячейку
	func dequeueReusableCell(
		withModel model: ICellViewAnyModel,
		for indexPath: IndexPath
	) -> UICollectionViewCell {
		let identifier = String(describing: type(of: model).cellAnyType)
		let cell = self.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
		model.setupAny(cell: cell)

		return cell
	}

	/// Метод для создания переиспользуемой вью
	/// - Parameters:
	///   - model: Модель данных
	///   - indexPath: Индекс ячейки
	/// - Returns: Сконфигурированную вью
	func dequeueReusableSupplementaryView(
		kind: String,
		withModel model: ICellViewAnyModel,
		for indexPath: IndexPath
	) -> UICollectionReusableView {
		let identifier = String(describing: type(of: model).cellAnyType)
		let view = self.dequeueReusableSupplementaryView(
			ofKind: kind,
			withReuseIdentifier: identifier,
			for: indexPath
		)
		model.setupAny(cell: view)

		return view
	}

	/// Метод для регистрации переиспользуемой ячейки
	/// - Parameter models: Модель данных
	func register(models: [ICellViewAnyModel.Type]) {
		for model in models {
			let identifier = String(describing: model.cellAnyType)
			self.register(model.cellAnyType, forCellWithReuseIdentifier: identifier)
		}
	}

	/// Метод для регистрации переиспользуемой вью
	/// - Parameter models: Модель данных
	func registerSupplementaryView(models: [(ICellViewAnyModel.Type, String)]) {
		for (model, kind) in models {
			let identifier = String(describing: model.cellAnyType)
			self.register(model.cellAnyType, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
		}
	}
}
