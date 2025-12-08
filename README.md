# MYL Tournament Admin App

Flutter admin application for managing the MYL Tournament.

## Setup

### Prerequisites
- Flutter SDK 3.10.1 or higher
- Dart SDK

### Installation

1. Clone the repository
2. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

3. Edit `.env` and add your API credentials:
   ```
   API_KEY=your_api_key_here
   BASE_URL=your_backend_url_here
   ```

4. Install dependencies:
   ```bash
   flutter pub get
   ```

5. Run the app:
   ```bash
   flutter run -d windows
   # or
   flutter run -d android
   # or
   flutter run -d ios
   ```

## Security

⚠️ **IMPORTANT**: Never commit the `.env` file to version control. It contains sensitive API credentials.

The `.env` file is already added to `.gitignore` to prevent accidental commits.

## Features

- Player management (create, confirm, view)
- Fixture generation with round-robin algorithm
- Match score recording
- Tournament standings tracking
- Round management with accordion UI

## Architecture

- **MVC Pattern**: Models, Views, Controllers separation
- **State Management**: Provider
- **HTTP Client**: http package
- **Environment Variables**: flutter_dotenv
