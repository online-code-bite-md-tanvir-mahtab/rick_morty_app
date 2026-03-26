# Rick and Morty Character Explorer (Flutter)

## 📌 Overview

This is a Flutter application that consumes the Rick and Morty API and demonstrates clean architecture, state management, offline-first behavior, and local data persistence.

The app allows users to browse characters, view details, mark favorites, and edit character data locally.

---

## 🚀 Features

### 🔹 Character List

* Fetches data from Rick and Morty API
* Infinite scroll pagination
* Displays:

  * Image
  * Name
  * Species
  * Status

### 🔹 Character Details

* Full character information:

  * Name
  * Status
  * Species
  * Type
  * Gender
  * Origin
  * Location
  * Image

### 🔹 Favorites

* Add/remove characters
* Dedicated favorites screen
* Persisted locally using Hive

### 🔹 Local Editing (Core Feature)

* Users can edit:

  * Name
  * Status
  * Species
  * Type
  * Gender
  * Origin
  * Location
* Edits are stored locally
* Edited data overrides API data across the app
* Changes persist after app restart

### 🔹 Offline Support

* API responses cached locally
* App works without internet
* Favorites and edited data remain accessible

---

## 🧠 Architecture

The project follows a clean, modular structure:

lib/

* core/ → network & utilities
* features/character/

  * data/ → models, datasource, repository
  * presentation/ → UI, providers

---

## ⚙️ State Management

Riverpod is used for state management because:

* Simple and scalable
* Good separation of concerns
* Easy async handling

---

## 💾 Local Storage

Hive is used for local persistence:

* Fast and lightweight
* Stores:

  * Cached API data
  * Favorites
  * Edited character overrides

---

## 🔄 Data Handling Strategy

The app maintains two sources of data:

1. API data (base)
2. Local edits (override)

At runtime:
Final UI data = API data + local overrides

This ensures:

* Edits persist
* API remains read-only

---

## 🧪 Testing

### Unit Test

* Tests merge logic (API + local edits)

### Widget Test

* Ensures main screen renders correctly

---

## 🛠️ Setup Instructions

1. Clone the repository
2. Run:

   ```bash
   flutter pub get
   ```
3. Generate Hive adapters:

   ```bash
   flutter pub run build_runner build
   ```
4. Run the app:

   ```bash
   flutter run
   ```

---

## 📦 Dependencies

* flutter_riverpod
* dio
* hive
* hive_flutter
* cached_network_image

---

## ⚠️ Known Limitations

* Basic UI (focused on functionality)
* No advanced filtering (optional feature)
* Limited test coverage (core logic covered)

---

## 🎯 Conclusion

This project demonstrates:

* Clean architecture
* Offline-first approach
* Real-world state management
* Proper data handling and persistence

