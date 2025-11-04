# Restaurant Store Flutter App

A Flutter mobile application for restaurant ordering that connects to the Spring Boot backend API.

## Features Implemented

### ✅ **Completed:**
- **Project Structure**: Complete Flutter project setup with proper folder organization
- **Dependencies**: All necessary packages configured in pubspec.yaml
- **State Management**: Provider pattern setup for app-wide state management
- **Networking**: Dio HTTP client with interceptors and error handling
- **Data Models**: Complete Dart models matching Spring Boot API DTOs
- **Authentication**: Auth provider with login, registration, and state persistence
- **Theming**: Custom Material Design theme with restaurant branding
- **Constants**: App configuration and styling constants

### ✅ **Recently Completed:**
- **Cart Provider**: Complete local cart state management with persistence
- **Product Provider**: Menu browsing, filtering, and search functionality
- **Order Provider**: Order placement, tracking, and payment processing
- **Splash Screen**: App initialization with smooth animations
- **Login Screen**: Authentication with form validation
- **Custom Widgets**: Reusable UI components (CustomButton, CustomTextField)

### 🚧 **In Progress:**
- Registration screen completion
- Main navigation screen
- Menu browsing UI (category list, product catalog)
- Cart and checkout screens
- Order tracking screens
- Delivery tracking screens

## Architecture

### State Management
- **Provider**: For app-wide state management
- **Local Storage**: Hive for offline data persistence
- **Shared Preferences**: For user preferences and auth tokens

### Networking
- **Dio HTTP Client**: RESTful API communication
- **Interceptors**: Automatic token injection and error handling
- **Generic API Service**: Type-safe request/response handling

### Data Models
- **Customer & Auth**: User authentication and profile management
- **Product & Category**: Menu items and categorization
- **Cart**: Local cart state with price calculations
- **Order**: Order placement and tracking
- **Delivery**: Real-time delivery status tracking

## Project Structure

```
lib/
├── constants/          # App constants and theming
├── models/            # Data models matching API DTOs
├── providers/         # State management providers
├── services/          # API and external services
├── screens/          # UI screens and pages
├── widgets/          # Reusable UI components
└── utils/            # Utility functions
```

## API Integration

The app connects to the Spring Boot backend at `http://localhost:8080/api` with the following endpoints:

- **Authentication**: `/auth/login`, `/auth/register`
- **Menu**: `/categories`, `/products`
- **Orders**: `/orders`, `/orders/{id}`
- **Delivery**: `/deliveries/{orderId}`

## Getting Started

1. **Prerequisites**
   ```bash
   flutter --version  # Ensure Flutter 3.0+ is installed
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

## Next Steps

The foundation is complete! Next implementation steps:

1. **Complete Providers**: Cart, Product, and Order providers
2. **Authentication UI**: Login and registration screens
3. **Menu Browsing**: Category list and product catalog
4. **Cart Functionality**: Add to cart, quantity management
5. **Order Placement**: Checkout flow with address and payment
6. **Order Tracking**: Real-time order status updates
7. **Delivery Tracking**: Live delivery status with driver info

## Key Features

### 🔐 Authentication
- JWT token-based authentication
- Persistent login state
- Profile management

### 🛒 Shopping Experience
- Category-based menu browsing
- Product search and filtering
- Local cart with price calculations
- Special instructions for items

### 📦 Order Management
- Order placement with delivery details
- Real-time order status tracking
- Order history
- Order cancellation

### 🚚 Delivery Tracking
- Live delivery status updates
- Driver information and contact
- Estimated delivery times
- GPS tracking integration ready

The app is designed to provide a seamless restaurant ordering experience with modern UI/UX patterns and robust state management!# -restaurant-store-flutter-y4
