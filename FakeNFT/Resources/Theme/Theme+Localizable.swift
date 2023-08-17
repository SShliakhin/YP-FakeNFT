import Foundation

extension Theme {
	enum ActionsNames {
		static var close: String {
			NSLocalizedString(
				"action.close",
				comment: "Действие: Закрыть"
			)
		}
		static var okey: String {
			NSLocalizedString(
				"action.OK",
				comment: "Действие: OK"
			)
		}
		static var retry: String {
			NSLocalizedString(
				"action.retry",
				comment: "Действие: Повторить запрос"
			)
		}
	}

	enum AlertTitles {
		static var errorTitle: String {
			NSLocalizedString(
				"alert.errorTitle",
				comment: "Заголок для алерта ошибки: Ошибка"
			)
		}
		static var sortTitle: String {
			NSLocalizedString(
				"alert.sortTitle",
				comment: "Заголок для алерта сортировки: Сортировка"
			)
		}
	}

	enum Author {
		static var incorrectURL: String {
			NSLocalizedString(
				"author.error.incorrectURL",
				comment: "Ошибка в url автора: Неверный адрес сайта автора"
			)
		}
		static var textPrefix: String {
			NSLocalizedString(
				"author.text.prefix",
				comment: "Префикс для текста автора в коллекции: Автор колллекции:"
			)
		}
	}

	enum NetworkError {
		static var brokenLikes: String {
			NSLocalizedString(
				"error.brokenLikes",
				comment: "Ошибка сети: Лайки сломаны."
			)
		}
		static var brokenOrder: String {
			NSLocalizedString(
				"error.brokenOrder",
				comment: "Ошибка сети: Заказ сломан."
			)
		}
		static var noAuthorByID: String {
			NSLocalizedString(
				"error.noAuthorByID",
				comment: "Ошибка сети: Автор с id %@ не получен."
			)
		}
		static var noCollections: String {
			NSLocalizedString(
				"error.noCollections",
				comment: "Ошибка сети: Коллекции не получены."
			)
		}
		static var noNftByID: String {
			NSLocalizedString(
				"error.noNftByID",
				comment: "Ошибка сети: Nft с id %@ не получен."
			)
		}
		static var noNfts: String {
			NSLocalizedString(
				"error.noNfts",
				comment: "Ошибка сети: Nfts не получены."
			)
		}
		static var noNftsByAuthorID: String {
			NSLocalizedString(
				"error.noNftsByAuthorID",
				comment: "Ошибка сети: Nfts по автору с id %@ не получены."
			)
		}
	}

	enum SortByTitle {
		static var name: String {
			NSLocalizedString(
				"sortBy.name",
				comment: "Заголовок опции сортировки по названию: По названию"
			)
		}
		static var nftsCount: String {
			NSLocalizedString(
				"sortBy.nftsCount",
				comment: "Заголовок опции сортировки по количеству NFT: По количеству NFT"
			)
		}
	}

	enum TabTitle {
		static var cart: String {
			NSLocalizedString(
				"tabTitle.cart",
				comment: "Заголовок таба: Корзина."
			)
		}
		static var catalog: String {
			NSLocalizedString(
				"tabTitle.catalog",
				comment: "Заголовок таба: Каталог."
			)
		}
		static var profile: String {
			NSLocalizedString(
				"tabTitle.profile",
				comment: "Заголовок таба: Профайл."
			)
		}
		static var stats: String {
			NSLocalizedString(
				"tabTitle.stats",
				comment: "Заголовок таба: Статистика."
			)
		}
	}
}
