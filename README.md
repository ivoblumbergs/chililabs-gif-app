# GIF App

I created this project by using Flutter, the Flutter version is (3.22.0). For dependencies I used:

- **Riverpod** – for managing the state
- **HTTP** – for network requests

---

## Getting Started

### Prerequisites

- Flutter SDK installed ([installation guide](https://docs.flutter.dev/get-started/install))
- A Giphy API key ([get one here](https://developers.giphy.com/))

### Setup

1. **Clone the repository**

   ```bash
   git clone <git@github.com:ivoblumbergs/chililabs-gif-app.git>
   cd gif_app
   ```

2. **Add your Giphy API key**

   Open `lib/secrets.dart` and replace the placeholder with your actual API key:

   ```dart
   // lib/secrets.dart
   const String giphyApiKey = 'YOUR_API_KEY_HERE';
   ```

3. **Install dependencies**

   ```bash
   flutter pub get
   ```

4. **Run the app**

   ```bash
   flutter run
   ```

---

## Project Structure

```
lib/
├── main.dart               # App entry point, ProviderScope wrapper
├── secrets.dart            # API key (not committed)
├── models/
│   └── gif.dart            # GIF data model
├── services/
│   └── giphy_service.dart  # API calls & JSON parsing
├── providers/
│   ├── gif_provider.dart   # GIF search state & pagination logic
│   └── search_provider.dart# Search query state
└── pages/
    └── main_screen.dart    # Main UI screen
```

---

## Project Overview

In `gif.dart` I created a simple GIF model to represent data from the API in a structured way. Instead of using JSON everywhere, I converted the data into a Dart object which makes the code cleaner and easier to maintain.

Then I created `giphy_service.dart` for making API calls and retrieving JSON, which then uses that GIF model constructor to convert JSON into a Dart object. This separation keeps the code cleaner and strongly typed, because the UI works with GIF objects instead of raw JSON maps.

I chose Riverpod for state management because I wanted to take the opportunity to learn something new, even though it was optional for a junior/intern task. It has a slightly steeper learning curve, but it helps keep the app's logic separate from the UI, which makes the code cleaner and easier to maintain in the long run.

So in `main.dart` I wrapped the app with `ProviderScope` so the provider can be read anywhere in the app.

For this app I created two providers:

### `search_provider.dart`

Holds a simple string state for the current search text. In `main_screen.dart`, I use `ref.watch(searchQueryProvider)` so the UI updates when the query changes. I also use `ref.read(searchQueryProvider.notifier).state = value` to update the query when the user types, and that value is then used to trigger the GIF search.

### `gif_provider.dart`

It manages the state of GIF search results by keeping track of:

- The current list of GIFs
- The current pagination offset
- Whether more GIFs are loading
- Any error messages

It does this with `GifState` which holds those values, and `GifNotifier` which contains the logic. `search(query)` fetches the first page for a new search, and `loadMore(query)` fetches the next page when the user scrolls down.

---

## Pagination

I created a `ScrollController` in `main_screen.dart` and added a listener inside `initState()` When the user scrolls within 200 pixels of the bottom, the app reads the current search query and calls `ref.read(gifProvider.notifier).loadMore(query)` so more GIFs are loaded as the user scrolls down.

The pagination state is stored in `GifState`:

- `offset` tracks how many GIFs have already been loaded
- `isLoadingMore` prevents duplicate requests

`loadMore()` checks `isLoadingMore` — if it is not already loading, it sets it to true, calls the API with the current offset, and then appends the new results to the existing list. That way each new page is added to the current GIF list instead of replacing it.

---

## Orientation

In `main_screen.dart` I used `MediaQuery` to track the current orientation of the device, then in the grid layout I used these values:

```dart
Orientation.portrait ? 2 : 3
```

In portrait mode it will show 2 columns and in landscape — 3.

---

## Error Handling

`GifNotifier.search()` and `GifNotifier.loadMore()` are wrapped in `try/catch` in `gif_provider.dart`
If the API call fails, the provider sets an `errorMessage` in the state.

In `giphy_service.dart` the API request checks for a 200 status code and throws an error if the response is not successful.

---

## GIF Detail View

For the GIF detail view I did not create a separate screen. Instead I wrapped each grid item in a `GestureDetector` and used `showDialog` on tap to display the selected GIF, resolution and size, and a share button placeholder.

---

## Unit Tests

I created three unit tests:

| File                        | What it tests                                                                                             |
| --------------------------- | --------------------------------------------------------------------------------------------------------- |
| `gif_model_test.dart`       | Checks if `gif.dart` will convert JSON into an object by checking if the returned object has the same URL |
| `gif_provider_test.dart`    | Checks the default state of the app and also checks if `copyWith()` is changing the given values          |
| `search_provider_test.dart` | Checks for search query states, for an empty state and when it updates                                    |

Run all tests with:

```bash
flutter test
```

---

## Try the App

To try this app you can download the APK:

> **[⬇️ Download APK](build/app-release.apk)**

Or if you don't want to install or build anything, I have provided you with a cloud emulator for mobile apps (appetize.io) where I uploaded the `.apk` file. I have to warn you — as I am on the free tier there is a time restriction of 3 minutes per session, but if you refresh the page the time resets.

> **[▶️ Launch on appetize.io](https://appetize.io/app/b_6ywm73usyt6423mjakthkqfn6q)**
