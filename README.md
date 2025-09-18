# mobile_assignment

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Project Structure

The `lib` directory contains the core source code of the application, organized as follows:

- `lib/models`: Contains the data models for the application, such as `Job` and `ServiceHistoryItem`. This separates the data layer from the UI and business logic.

- `lib/pages`: Each file in this directory represents a different page or screen in the application. This helps to keep the UI for each feature organized and easy to find.

- `lib/services`: This directory is for services that interact with external resources, such as APIs or databases. For example, `SupabaseService` handles communication with the Supabase backend.

- `lib/widgets`: Contains reusable UI components that are shared across multiple pages. This promotes code reuse and a consistent look and feel throughout the app.

- `lib/main.dart`: The main entry point of the application.