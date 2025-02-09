# TOT Application

A Flutter application for displaying dogs, liking them, and monitoring their real-time location.

## Project Structure

```
lib/
├── bloc/               # State management
│   ├── dog_bloc/      # Dog-related business logic
│   └── map_bloc/      # Map-related business logic
├── constants/         # App-wide constants and theming
├── data/
│   └── model/        # Data models
├── repositories/      # Data layer handlers and API services
├── presentation/     
│   └── widgets/      # UI components
└── services/         # API and other services
```

## API Integration
This app fetches dog data from the following endpoint:

```
GET https://freetestapi.com/api/v1/dogs
```

The API supports query parameters for filtering, pagination, and sorting.

## Features
- Fetch and display a list of dogs
- Like and save favorite dogs
- Real-time location tracking
- Walk feature to monitor journeys
- Map integration

## Video Demo

[Watch Demo](https://github.com/user-attachments/assets/4baf4be8-ea0b-4ed6-be90-5ac9420dcc2d)

## Getting Started
1. Ensure Flutter is installed on your machine.
2. Clone the repository.
3. Run `flutter pub get` to install dependencies.
4. Run `flutter run` to start the application.

For more details about specific features, please refer to the documentation in respective directories.

