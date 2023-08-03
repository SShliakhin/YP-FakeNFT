import Foundation

final class NetworkTask {
	private var task: URLSessionTask?
	private var cancelled = false

	let queue = DispatchQueue(label: "ru.sas.networkTask", qos: .utility)

	func cancel() {
		queue.sync {
			cancelled = true

			if let task = task {
				task.cancel()
			}
		}
	}

	func set(_ task: URLSessionTask) {
		queue.sync {
			self.task = task

			if cancelled {
				task.cancel()
			}
		}
	}
}
