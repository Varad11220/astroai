# AstroAI: Your Personal Astrology Bot

A cross-platform app with secure OTP-based authentication and astrological insights.

- **Authentication:** Users sign up or log in using their email. OTPs are sent securely via SMTP email for verification.
- **User Data Collection:** The app collects date of birth, time of birth, place of birth, and name to provide personalized astrological insights.
- **Astrological Prediction:** The backend  uses the Gemini generative AI model to generate astrological predictions based on user input and calculated planetary positions.

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Node.js & npm](https://nodejs.org/)
- [Git](https://git-scm.com/)

---

## 1. Flutter Frontend (`astroai/`)

### Setup

```sh
cd astroai
flutter pub get
```

### Running the App

- **Mobile/Web:**  
  ```sh
  flutter run
  ```
- **Web:**  
  ```sh
  flutter run -d chrome
  ```

### Firebase

This project uses [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) for Firebase integration.

- To set up Firebase, run:
  ```sh
  flutterfire configure
  ```
- This will generate `lib/firebase_options.dart` (which is gitignored for security).
- You still need to add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) as needed.

---

## 2. Node.js Backend (`emailer/`)

### Setup

```sh
cd emailer
npm install
```

### Running the Server

```sh
node server.js
```
or (if you use nodemon for development)
```sh
npx nodemon server.js
```

### Environment Variables

- Create a `.env` file in `emailer/` for sensitive configuration (see `.gitignore`).
- Example `.env` format:

  ```env
  # .env example for emailer backend
  
  # Server
  PORT=3000
  
  # MongoDB
  MONGO_URI=your_mongodb_connection_string
  
  # Gemini API
  GEMINI_API_KEY=your_gemini_api_key
  
  # Email (SMTP)
  SMTP_USER=your_email@gmail.com
  SMTP_PASS=your_email_password
  ```

---

## Development & Contribution

1. Fork and clone the repository.
2. Create a new branch for your feature or bugfix.
3. Make your changes and commit them with clear messages.
4. Push your branch and open a Pull Request.

---

## Folder Overview

- `astroai/`  
  Flutter app source code, screens, services, widgets, and configs.
- `astroai/emailer/`  
  Node.js backend, routes, controllers, models, and utilities.

---

## Contributors

- [@Varad11220](https://github.com/Varad11220)
- [@YashD15](https://github.com/YashD15)


---

## Useful Commands

- **Flutter:**  
  - `flutter pub get` – Install dependencies  
  - `flutter run` – Run the app  
  - `flutter build apk` – Build Android APK

- **Node.js:**  
  - `npm install` – Install dependencies  
  - `node server.js` – Start backend server

---

## License

This project is licensed under the [MIT License](emailer/LICENSE).

---

## Contact

For questions or support, open an issue or contact the maintainer.

---

## API Configuration

The Flutter app communicates with the backend using a base URL defined in `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Base URL for API calls
  static const String baseUrl = 'https://api.example.com';
}
```

- Update `baseUrl` if you deploy the backend to a different server or environment.
