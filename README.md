# Bazapp

Bazapp is a geolocation-based social media app developed using Flutter. It allows users to connect with others nearby, share updates, and discover events and places around them.

## Features

- **Geolocation-based Posts**: Users can create and share Events based on their current location, allowing them to connect with others in their vicinity.
  
- **Messaging**: Bazapp includes a messaging feature that enables users to communicate with each other privately.
  
- **Events and Places**: Users can discover events and places nearby, making it easy to find interesting activities and venues.

- **Preferences**: Bazapp offers customizable preferences, including dark mode support and notification settings.

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/pgattic/bazapp.git
   ```
2. Navigate to the project directory:
   ```bash
   cd bazapp
   ```
3. Install dependencies: 
   ```bash
   flutter pub get
   ```
4. You are meant to supply your own API keys into the `lib/firebase/firebase_options.dart` file. We have excluded ours in order to prevent abuse.
5. Run the app:
   ```bash
   flutter run
   ```

## Contributing

Contributions to Bazapp are welcome! If you encounter any issues or have ideas for new features, feel free to open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).

## Acknowledgements

Bazapp uses the following open-source packages:

- [Firebase](https://firebase.google.com/): For authentication, messaging, and data storage.
- [Provider](https://pub.dev/packages/provider): For state management.
- [Flutter Map](https://pub.dev/packages/flutter_map): For displaying maps and geolocation data.
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications): For displaying local notifications.
- [Cloud Firestore](https://pub.dev/packages/cloud_firestore): For real-time database functionality.

## About

Bazapp was developed by Bryant Van Orden and Preston Corless as a team for our Senior Project at BYU-Idaho. For inquiries, contact Supermanismebvo123@gmail.com or pgattic@gmail.com.

