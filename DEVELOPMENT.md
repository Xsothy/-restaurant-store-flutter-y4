# Development Guide

This guide provides comprehensive information for developers working on the Restaurant Store Flutter application.

## 📋 Table of Contents

- [Setup](#setup)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
- [Code Generation](#code-generation)
- [State Management](#state-management)
- [API Integration](#api-integration)
- [Testing](#testing)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)

## 🚀 Setup

### Prerequisites

- **Flutter SDK**: >= 3.10.0
- **Dart SDK**: >= 3.0.0
- **IDE**: Android Studio, VS Code, or IntelliJ IDEA
- **Git**: For version control

### Initial Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd restaurant_store_flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Development Scripts

Use the provided development script for common tasks:

```bash
# Make the script executable (once)
chmod +x scripts/dev.sh

# Run the development menu
./scripts/dev.sh
```

## 🏗️ Project Structure

```
restaurant_store_flutter/
├── lib/
│   ├── constants/          # App constants and themes
│   │   ├── app_constants.dart    # Global constants
│   │   └── theme.dart          # App theming
│   ├── models/            # Data models with JSON serialization
│   │   ├── user.dart            # User-related models
│   │   ├── product.dart         # Product and category models
│   │   ├── cart.dart            # Cart management models
│   │   └── order.dart           # Order and delivery models
│   ├── providers/         # State management
│   │   ├── auth_provider.dart    # Authentication state
│   │   ├── cart_provider.dart    # Shopping cart state
│   │   ├── product_provider.dart # Product browsing state
│   │   └── order_provider.dart  # Order management state
│   ├── services/          # External services
│   │   ├── api_service.dart     # HTTP client and API calls
│   │   └── storage_service.dart # Local storage management
│   ├── screens/           # UI screens
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── menu_screen.dart
│   │   ├── product_detail_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── checkout_screen.dart
│   │   ├── order_tracking_screen.dart
│   │   ├── profile_screen.dart
│   │   └── order_history_screen.dart
│   ├── widgets/           # Reusable UI components
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   └── ... (more widgets)
│   ├── utils/             # Utility functions
│   │   └── routes.dart         # Navigation configuration
│   └── main.dart          # App entry point
├── assets/               # Static assets
│   ├── images/           # Image files
│   ├── animations/       # Lottie animations
│   ├── icons/           # App icons
│   └── fonts/           # Custom fonts
├── test/                # Test files
├── scripts/             # Development scripts
├── pubspec.yaml         # Dependencies and configuration
└── README.md           # Project documentation
```

## 🔄 Development Workflow

### 1. Feature Development

1. **Create a new branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow the existing code style and patterns
   - Add tests for new functionality
   - Update documentation if needed

3. **Run code generation** (if you modified models)
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run tests**
   ```bash
   flutter test
   ```

5. **Analyze code**
   ```bash
   flutter analyze
   ```

6. **Commit changes**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

7. **Push and create PR**
   ```bash
   git push origin feature/your-feature-name
   ```

### 2. Code Style Guidelines

- **Dart Style**: Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- **Widget Naming**: Use PascalCase for widgets
- **File Naming**: Use snake_case for files
- **Constants**: Use UPPER_SNAKE_CASE for constants
- **Private Members**: Prefix with underscore (`_`)

### 3. Git Conventional Commits

Use conventional commit messages:

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `test:` Adding or updating tests
- `chore:` Maintenance tasks

## 🔧 Code Generation

### JSON Serialization

The project uses `json_annotation` and `json_serializable` for automatic JSON serialization.

#### Adding New Models

1. **Create the model class** with annotations:
   ```dart
   import 'package:json_annotation/json_annotation.dart';
   
   part 'your_model.g.dart';
   
   @JsonSerializable()
   class YourModel {
     final int id;
     final String name;
     
     YourModel({required this.id, required this.name});
     
     factory YourModel.fromJson(Map<String, dynamic> json) => _$YourModelFromJson(json);
     Map<String, dynamic> toJson() => _$YourModelToJson(this);
   }
   ```

2. **Run code generation**:
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

3. **Use the generated methods** in your code.

### Watching for Changes

For development, you can use the watch mode:

```bash
flutter packages pub run build_runner watch --delete-conflicting-outputs
```

## 📊 State Management

### Provider Pattern

The app uses the Provider pattern for state management:

#### Key Concepts

1. **ChangeNotifier**: Base class for state management
2. **Consumer**: Widget that rebuilds when provider changes
3. **Provider**: Widget that provides state to descendants
4. **Context.read()**: Read provider without rebuilding
5. **Context.watch()**: Read provider and rebuild on changes

#### Example Usage

```dart
// Reading state
final authProvider = context.watch<AuthProvider>();
final user = authProvider.user;

// Writing state
context.read<CartProvider>().addToCart(product);

// Listening to changes
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    return Text('Welcome ${authProvider.user?.name}');
  },
)
```

### Provider Architecture

- **AuthProvider**: Authentication and user management
- **CartProvider**: Shopping cart state
- **ProductProvider**: Product browsing and filtering
- **OrderProvider**: Order management and tracking

## 🌐 API Integration

### Dio HTTP Client

The app uses Dio for HTTP requests with the following features:

- **Interceptors**: Automatic token injection and error handling
- **Logging**: Request/response logging for debugging
- **Error Handling**: Centralized error handling with user-friendly messages
- **Retry Logic**: Automatic retry for failed requests

### API Service Structure

```dart
// Example API call
static Future<List<Product>> getProducts({
  int? categoryId,
  String? search,
  // ... other parameters
}) async {
  try {
    final response = await _dio.get('/products', queryParameters: {
      if (categoryId != null) 'categoryId': categoryId,
      if (search != null) 'search': search,
    });
    
    final List<dynamic> data = response.data['content'] ?? response.data;
    return data.map((json) => Product.fromJson(json)).toList();
  } on DioException catch (e) {
    throw _handleError(e);
  }
}
```

### Error Handling

All API errors are handled centrally and converted to user-friendly messages:

```dart
static String _handleError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      return AppConstants.networkError;
    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode;
      final message = e.response?.data?['message'] ?? 'Unknown error';
      
      switch (statusCode) {
        case 401:
          return AppConstants.authError;
        case 404:
          return 'Resource not found: $message';
        // ... more cases
      }
      break;
    // ... more cases
  }
  return AppConstants.generalError;
}
```

## 🧪 Testing

### Test Structure

```
test/
├── unit/               # Unit tests
├── widget/             # Widget tests
├── integration/        # Integration tests
└── test_utils.dart     # Test utilities
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

### Writing Tests

#### Widget Tests

```dart
testWidgets('Login form validation', (WidgetTester tester) async {
  // Build the widget
  await tester.pumpWidget(const LoginScreen());
  
  // Find widgets
  final emailField = find.byKey(Key('email_field'));
  final passwordField = find.byKey(Key('password_field'));
  final loginButton = find.byKey(Key('login_button'));
  
  // Enter text
  await tester.enterText(emailField, 'invalid-email');
  await tester.enterText(passwordField, 'password');
  
  // Tap button
  await tester.tap(loginButton);
  await tester.pump();
  
  // Verify error message
  expect(find.text('Please enter a valid email'), findsOneWidget);
});
```

## 📱 Deployment

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### iOS

```bash
# Build iOS app
flutter build ios --release

# Open in Xcode
open ios/Runner.xcworkspace
```

### Web

```bash
# Build for web
flutter build web --release
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Code Generation Errors

**Problem**: `Missing "part" directive` errors

**Solution**:
```bash
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### 2. Provider Not Found

**Problem**: `Provider not found` errors

**Solution**: Ensure providers are properly wrapped in the widget tree:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    // ... other providers
  ],
  child: MaterialApp(...),
)
```

#### 3. Navigation Issues

**Problem**: Navigation not working

**Solution**: Check route configuration and context usage:

```dart
// Correct way to navigate
context.go('/home');

// Make sure you're in the right context
Builder(
  builder: (context) => ElevatedButton(
    onPressed: () => context.go('/home'),
    child: Text('Go Home'),
  ),
)
```

#### 4. State Not Updating

**Problem**: UI not updating when state changes

**Solution**: Ensure you're calling `notifyListeners()` in your provider:

```dart
void updateState() {
  _state = newState;
  notifyListeners(); // Important!
}
```

### Debugging Tips

1. **Use Flutter Inspector**: Visual widget tree inspection
2. **Enable Logging**: Check network requests and responses
3. **Hot Reload**: Use hot reload for quick iterations
4. **Debug Prints**: Add debug prints for state changes
5. **Breakpoints**: Use IDE debugger for complex issues

### Performance Optimization

1. **Use const constructors**: For widgets that don't change
2. **Avoid unnecessary rebuilds**: Use Consumer selectively
3. **Image optimization**: Use appropriate image sizes and formats
4. **List optimization**: Use ListView.builder for long lists
5. **Memory management**: Dispose controllers and listeners

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [Provider Package](https://pub.dev/packages/provider)
- [Dio HTTP Client](https://pub.dev/packages/dio)
- [Material Design 3](https://m3.material.io/)

## 🤝 Contributing

1. Follow the development workflow
2. Write tests for new features
3. Update documentation
4. Follow code style guidelines
5. Create pull requests with clear descriptions

---

For any questions or issues, please refer to the main README.md or create an issue in the repository.
