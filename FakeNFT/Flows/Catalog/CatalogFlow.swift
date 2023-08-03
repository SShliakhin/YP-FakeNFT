import UIKit

struct CatalogFlow: IFlow {
	func start() -> UIViewController {
		CatalogViewController()
	}
}
