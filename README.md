# Introgy App

A Flutter-based application for managing social energy, wellbeing, and connections. This app helps users track their social battery, manage relationships, and improve overall wellbeing through AI-powered insights.

## Features

### Authentication
- Google and Apple Sign-In
- Secure authentication flow with Supabase
- User onboarding process

### Social Battery
- Track and visualize your social energy levels
- Manage upcoming social events
- Quick actions for common social situations

### Connections Builder
- Manage and categorize your social connections
- Filter connections based on various criteria
- Get AI-powered suggestions for strengthening relationships

### Wellbeing
- Track your mood and wellbeing metrics
- Access wellbeing resources and tips
- View personalized wellbeing statistics

### Profile
- Manage your personal information
- Customize app preferences
- Get AI-generated bio suggestions based on your interests and personality
- Receive personalized wellbeing tips

## AI Integration

The app uses HuggingFace's AI models to generate personalized content:

- **Bio Generation**: Creates personalized bio suggestions based on your interests and personality traits
- **Wellbeing Tips**: Provides customized wellbeing advice based on your profile
- **Connection Suggestions**: Offers ideas to strengthen specific relationships
- **Social Battery Management**: Gives tips for managing social energy based on your current battery level

## Setup

### Environment Variables

Create a `.env` file in the root directory with the following variables:

```
HUGGINGFACE_API_KEY=your_huggingface_api_key_here
```

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure your Supabase and Firebase projects
4. Update the Supabase and Firebase configuration in `main.dart`
5. Run the app with `flutter run`

## Architecture

The app follows a feature-first architecture with clean separation of concerns:

- **Models**: Data structures for each feature
- **Repositories**: Data access and business logic
- **Providers**: State management using Riverpod
- **Presentation**: UI components (screens and widgets)

## Dependencies

- **State Management**: flutter_riverpod
- **Navigation**: go_router
- **Backend**: supabase_flutter, firebase_core
- **Authentication**: google_sign_in, sign_in_with_apple
- **AI and Networking**: http, flutter_dotenv
- **UI Components**: flutter_svg, lottie, cached_network_image

For a complete list of dependencies, see the `pubspec.yaml` file.
