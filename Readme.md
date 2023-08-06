# FakeNFT

Приложение помогает пользователям просматривать и покупать NFT (Non-Fungible Token). Функционал покупки иммитируется с помощью мокового сервера.

Цели приложения:

- просмотр коллекций NFT;
- просмотр и покупка NFT (иммитируется);
- просмотр рейтинга пользователей.

# Table of Contents
1. [Description](#description)
2. [Getting started](#getting-started)
3. [Usage](#usage)
4. [Arhitecture](#arhitecture)
5. [Structure](#structure)
6. [Dependencies](#dependencies)
7. [Workflow](#workflow)
8. [Task board](#task-board)
9. [Design](#design)

# Description

- Приложение демонстрирует каталог NFT, структурированных в виде коллекций
- Пользователь может посмотреть информацию о каталоге коллекций, выбранной коллекции и выбранном NFT.
- Пользователь может добавлять понравившиеся NFT в избранное.
- Пользователь может удалять и добавлять товары в корзину, а также оплачивать заказ (покупка иммитируется).
- Пользователь может посмотреть рейтинг пользователей и информацию о пользователях.
- Пользователь может смотреть информацию и своем профиле, включая информацию об избранных и принадлежащих ему NFT.

Полное описание функциональных требований находится в [техническом задании](https://github.com/Yandex-Practicum/iOS-FakeNFT-StarterProject-Public/blob/main/Readme.md)

# Getting started

1. Убедитесь что на компьютере установлен Xcode версии 13 или выше.
2. Загрузите файлы Tracker проекта из репозитория.
3. Откройте файл проекта в Xcode.
5. Запустите активную схему.

# Usage

[In progress]

# Architecture

* MVVM
* DI: на базе фабрик
* Layout: Anchors, CompositionalLayout

# Structure

* "Core": глобальные объекты приложения
* "Flows": Независимые флоу, с набором моделей, сцен и сервисов, согласно эпику
* "Library": Протоколы, расширения и утилиты
* "Resources": Ресурсы приложения: картинки, шрифты и другие типы ресурсов. А также файлы и группы файлов:
    - Theme+.swift - расширения, которые содержат статические методы по поддержке работы с ресурсами приложения и некоторые дополнительные сервисные методы.
    - LaunchScreen.storyboard
    - Info.plist

# Dependencies

[In progress]

# Workflow

[In progress]

## Branches

* main - стабильные версии приложения
* develop - ветка для разработки и создания PR для ревью
* base - ветка начальной/общей конфигурации
* epic-NAME - ветки для работы над эпиками/флоу, создаются на основе начальной конфигурации из base, могут брать новые данные из base, вливаются через PR в develop

## Requirements for commit

* Названия коммитов должны быть согласно [гайдлайну](https://www.conventionalcommits.org/ru/v1.0.0/)
* Тип коммита должен быть только в нижнием регистре (feat, fix, refactor, docs и т.д.)
* Должен использоваться present tense ("add feature" not "added feature")
* Должен использоваться imperative mood ("move cursor to..." not "moves cursor to...")

### Examples

* `feat:` - это реализованная новая функциональность из технического задания (добавил поддержку зумирования, добавил footer, добавил карточку продукта). Примеры:

```
feat: add basic page layout
feat: implement search box
feat: implement request to youtube API
feat: implement swipe for horizontal list
feat: add additional navigation button
```

* `fix:` - исправил ошибку в ранее реализованной функциональности. Примеры:

```
fix: implement correct loading data from youtube
fix: change layout for video items to fix bugs
fix: relayout header for firefox
fix: adjust social links for mobile
```

* `refactor:` - новой функциональности не добавлял / поведения не менял. Файлы в другие места положил, удалил, добавил. Изменил форматирование кода (white-space, formatting, missing semi-colons, etc). Улучшил алгоритм, без изменения функциональности. Примеры:

```
refactor: change structure of the project
refactor: rename vars for better readability
refactor: apply prettier
```

* `docs:` - используется при работе с документацией/readme проекта. Примеры:

```
docs: update readme with additional information
docs: update description of run() method
```

[Источник](https://docs.rs.school/#/git-convention?id=%d0%9f%d1%80%d0%b8%d0%bc%d0%b5%d1%80%d1%8b-%d0%b8%d0%bc%d0%b5%d0%bd-%d0%ba%d0%be%d0%bc%d0%bc%d0%b8%d1%82%d0%be%d0%b2)

* `style: clean up` - корректирую/улучшаю стиль и читаемость кода, удаляю мертвый код 

## Tools

В проекте используются:

- [SwiftLint](https://github.com/realm/SwiftLint) - для обеспечения соблюдения стиля и соглашений Swift

```sh
brew update
brew install swiftlint
```

- Live Preview с помощью SwifUI

```swift
#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct ViewProvider: PreviewProvider {
	static var previews: some View {
		let viewController = ViewController()
		let labelView = viewController.makeWelcomeLabel() as UIView
		let labelView2 = viewController.makeWelcomeLabel() as UIView
		Group {
			viewController.preview()
			VStack(spacing: 0) {
				labelView.preview().frame(height: 100).padding(.bottom, 20)
				labelView2.preview().frame(height: 100).padding(.bottom, 20)
			}
		}
	}
}
#endif
```

# Task board

[In progress]

# Design

* Инструментом для дизайна является [Figma](https://www.figma.com)
* [Дизайн приложения](https://www.figma.com/file/k1LcgXHGTHIeiCv4XuPbND/FakeNFT-(YP)?node-id=96-5542&t=YdNbOI8EcqdYmDeg-0)

