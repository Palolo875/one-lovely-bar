# WeatherNav 🌦️🗺️

**WeatherNav** is an intelligent navigation application that seamlessly integrates contextual weather data, providing a unified and comprehensive travel experience.

## 🚀 Features

*   **Advanced Mapping:** Interactive maps with 3D terrain and vector styling utilizing `maplibre_gl` for smooth rendering across both mobile and web platforms.
*   **Contextual Weather Data:** Precise and localized weather information integrated directly into your navigation route, including an "Expert Weather" layer for deep insights.
*   **Smart Routing:** Effortlessly find your way with intelligent routing capabilities.
*   **Modern UI/UX:** Clean, responsive, and dynamic user interface with custom interactive elements, glance views, and smooth animations.

## 🛠️ Technology Stack

This project is built using the latest modern Flutter ecosystem components to guarantee performance, maintainability, and code quality.

*   **Framework:** [Flutter](https://flutter.dev/) (SDK version 3.10+)
*   **State Management:** [Riverpod](https://riverpod.dev/) (`flutter_riverpod`, `riverpod_annotation`)
*   **Navigation / Routing:** [GoRouter](https://pub.dev/packages/go_router)
*   **Maps & Location:** [Maplibre GL](https://pub.dev/packages/maplibre_gl) & [Geolocator](https://pub.dev/packages/geolocator)
*   **Networking:** [Dio](https://pub.dev/packages/dio)
*   **Data Models:** [Freezed](https://pub.dev/packages/freezed) & [JSON Serializable](https://pub.dev/packages/json_serializable)
*   **Local Storage:** [Hive](https://pub.dev/packages/hive) (Fast NoSQL Database)

## 🏗️ Architecture

The project strictly follows a **Clean Architecture** approach to separate concerns and improve structure:

*   `lib/core/` - Foundational utilities, styles, and configurations.
*   `lib/data/` - API clients, local storage services, and data repositories.
*   `lib/domain/` - Business logic, use cases, and abstract data models.
*   `lib/presentation/` - UI components divided by features, screens, state notifiers, and widgets.

## 💻 Getting Started

To run this project locally, ensure you have the [Flutter SDK installed](https://docs.flutter.dev/get-started/install).

1.  **Clone the repository:**
    ```bash
    git clone <YOUR_GIT_URL>
    cd one-lovely-bar
    ```

2.  **Fetch dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Generate code (Freezed / Riverpod / JSON Serializable):**
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the application:**
    ```bash
    flutter run
    ```
