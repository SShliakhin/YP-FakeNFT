import Foundation

enum L10n {
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
		static var noProfile: String {
			NSLocalizedString(
				"error.noProfile",
				comment: "Ошибка сети: Профайл не получен."
			)
		}
		static var noAuthors: String {
			NSLocalizedString(
				"error.noAuthors",
				comment: "Ошибка сети: Авторы не получены."
			)
		}
	}

	enum Onboarding {
		static let titleExplore = NSLocalizedString(
			"onboarding.explore.title",
			comment: "Заголовок страницы онбординга: Исследуйте."
		)
		static let titleCollect = NSLocalizedString(
			"onboarding.collect.title",
			comment: "Заголовок страницы онбординга: Коллекционируйте."
		)
		static let titleCompete = NSLocalizedString(
			"onboarding.compete.title",
			comment: "Заголовок страницы онбординга: Состязайтесь."
		)
		static let textExplore = NSLocalizedString(
			"onboarding.explore.text",
			comment: "Текст страницы онбординга Исследуйте"
		)
		static let textCollect = NSLocalizedString(
			"onboarding.collect.text",
			comment: "Текст страницы онбординга Коллекционируйте"
		)
		static let textCompete = NSLocalizedString(
			"onboarding.compete.text",
			comment: "Текст страницы онбординга Состязайтесь"
		)
	}

	enum Profile {
		static var incorrectURL: String {
			NSLocalizedString(
				"profile.error.incorrectURL",
				comment: "Ошибка в url разработчика: Неверный адрес сайта разработчика"
			)
		}
		static var aboutCall: String {
			NSLocalizedString(
				"profile.titleCall.about",
				comment: "Заголовок для вызова экрана: О разработчике"
			)
		}
		static var favoritesCall: String {
			NSLocalizedString(
				"profile.titleCall.favorites",
				comment: "Заголовок для вызова экрана: Избранные NFT (%d)"
			)
		}
		static var myNftsCall: String {
			NSLocalizedString(
				"profile.titleCall.myNtfs",
				comment: "Заголовок для вызова экрана: Мои NFT (%d)"
			)
		}
		static var searchNftsCall: String {
			NSLocalizedString(
				"profile.titleCall.searchNtfs",
				comment: "Заголовок для вызова экрана: Поиск NFTs по названию"
			)
		}
		static var editTitleName: String {
			NSLocalizedString(
				"profile.editTitle.name",
				comment: "Заголовок для редактирования профиля: Имя"
			)
		}
		static var editTitleDescription: String {
			NSLocalizedString(
				"profile.editTitle.description",
				comment: "Заголовок для редактирования профиля: Описание"
			)
		}
		static var editTitleWebsite: String {
			NSLocalizedString(
				"profile.editTitle.website",
				comment: "Заголовок для редактирования профиля: Сайт"
			)
		}
		static var buttonTitleChangePhoto: String {
			NSLocalizedString(
				"profile.buttonTitle.changePhoto",
				comment: "Заголовок кнопки: Сменить фото"
			)
		}
		static var buttonTitleUploadImage: String {
			NSLocalizedString(
				"profile.buttonTitle.uploadImage",
				comment: "Заголовок кнопки: Загрузить изображение"
			)
		}
		static var someTextBy: String {
			NSLocalizedString(
				"profile.someText.by",
				comment: "Некоторый текст: от"
			)
		}
		static var someTextPrice: String {
			NSLocalizedString(
				"profile.someText.price",
				comment: "Некоторый текст: Цена"
			)
		}
		static var emptyVCFavorites: String {
			NSLocalizedString(
				"profile.emptyVC.favorites",
				comment: "Сообщение для пустого экрана: У Вас ещё нет избранных NFT"
			)
		}
		static var emptyVCMyNFTs: String {
			NSLocalizedString(
				"profile.emptyVC.myNFTs",
				comment: "Сообщение для пустого экрана: У Вас ещё нет NFT"
			)
		}
		static var titleVCFavorites: String {
			NSLocalizedString(
				"profile.titleVC.favorites",
				comment: "Заголовок экрана: Избранные NFT"
			)
		}
		static var titleVCMyNFTs: String {
			NSLocalizedString(
				"profile.titleVC.myNFTs",
				comment: "Заголовок экрана: Мои NFT"
			)
		}
		static var titleVCSearchResult: String {
			NSLocalizedString(
				"profile.titleVC.searchVC.result",
				comment: "Заголовок экрана Поиск NFT: Найдено: %d"
			)
		}
		static var titleVCSearchInvite: String {
			NSLocalizedString(
				"profile.titleVC.searchVC.invite",
				comment: "Заголовок экрана Поиск NFT: Что будем искать?"
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
		static var price: String {
			NSLocalizedString(
				"sortBy.price",
				comment: "Заголовок опции сортировки по названию: По цене"
			)
		}
		static var rating: String {
			NSLocalizedString(
				"sortBy.rating",
				comment: "Заголовок опции сортировки по названию: По рейтингу"
			)
		}
	}

	enum SearchBar {
		static var noSearchResult: String {
			NSLocalizedString(
				"searchBar.emptyVC.noSearchResult",
				comment: "Сообщение для не успешного поиска: Нет результатов поиска"
			)
		}
		static var SearchByTitle: String {
			NSLocalizedString(
				"searchBar.placeholder.SearchByTitle",
				comment: "Плейсхолдер для поиска по названию: Поиск по названию"
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
