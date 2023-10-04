import UIKit
#if canImport(Connectivity)
import Connectivity
#endif

protocol NetworkMonitor {
	var isConnected: Bool { get }
}

final class NetworkMonitorImp: NetworkMonitor {
#if canImport(Connectivity)
	private let connectivity = Connectivity()
#endif

	var isConnected: Bool {
#if canImport(Connectivity)
		return connectivity.isConnected
#else
		return true
#endif
	}

	init() {
#if canImport(Connectivity)
		connectivity.framework = .network
		connectivity.startNotifier()
#endif
	}

	deinit {
#if canImport(Connectivity)
		connectivity.stopNotifier()
#endif
	}
}
