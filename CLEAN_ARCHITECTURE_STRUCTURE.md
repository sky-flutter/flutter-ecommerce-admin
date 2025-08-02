# Clean Architecture Structure - Ecommerce Admin Panel

## 🏗️ Project Structure Overview

```
lib/
├── main.dart                          # Application entry point
├── firebase_options.dart              # Firebase configuration
├── core/                             # Core application components
│   ├── constants/                    # App-wide constants
│   │   └── app_constants.dart       # Application constants
│   ├── infrastructure/               # External services
│   │   ├── firebase/                # Firebase services
│   │   │   ├── auth_service.dart
│   │   │   ├── custom_auth_service.dart
│   │   │   ├── firestore_service.dart
│   │   │   ├── storage_service.dart
│   │   │   ├── role_service.dart
│   │   │   ├── cloudinary_service.dart
│   │   │   └── logout_service.dart
│   │   ├── network/                 # Network services (future)
│   │   └── storage/                 # Local storage (future)
│   ├── theme/                       # Theme configuration (future)
│   ├── utils/                       # Utility functions (future)
│   ├── exceptions/                  # Custom exceptions (future)
│   └── core.dart                    # Core barrel file
├── features/                        # Feature-based modules
│   ├── auth/                        # Authentication feature
│   │   ├── domain/                  # Business logic
│   │   │   ├── entities/           # Business entities
│   │   │   │   └── auth_user.dart
│   │   │   ├── repositories/       # Repository interfaces
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/          # Use cases
│   │   │       ├── sign_in_usecase.dart
│   │   │       └── sign_out_usecase.dart
│   │   ├── data/                   # Data layer (future)
│   │   │   ├── models/            # Data models
│   │   │   ├── repositories/      # Repository implementations
│   │   │   └── datasources/       # Data sources
│   │   └── presentation/          # UI layer
│   │       ├── pages/             # Feature pages
│   │       │   └── login_page.dart
│   │       └── providers/         # State management
│   │           ├── auth_provider.dart
│   │           └── custom_auth_provider.dart
│   │   └── auth.dart              # Feature barrel file
│   ├── dashboard/                  # Dashboard feature
│   │   └── presentation/
│   │       └── pages/
│   │           └── dashboard_page.dart
│   │   └── dashboard.dart         # Feature barrel file
│   ├── products/                   # Products management
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── products_page.dart
│   │       │   ├── add_product_page.dart
│   │       │   ├── product_details_page.dart
│   │       │   └── product_details_page_new.dart
│   │       └── providers/
│   │           └── product_provider.dart
│   │   └── products.dart          # Feature barrel file
│   ├── orders/                     # Orders management
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── orders_page.dart
│   │       │   └── order_details_page.dart
│   │       └── providers/
│   │           └── order_provider.dart
│   │   └── orders.dart            # Feature barrel file
│   ├── users/                      # User management
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── users_page.dart
│   │       │   ├── add_user_page.dart
│   │       │   └── edit_user_page.dart
│   │       └── providers/
│   │           └── user_provider.dart
│   │   └── users.dart             # Feature barrel file
│   ├── settings/                   # Settings feature
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── settings_page.dart
│   │       │   ├── payment_settings_page.dart
│   │       │   ├── email_settings_page.dart
│   │       │   ├── store_info_page.dart
│   │       │   └── shipping_page.dart
│   │       └── providers/
│   │           └── settings_provider.dart
│   │   └── settings.dart          # Feature barrel file
│   ├── analytics/                  # Analytics feature
│   │   └── presentation/
│   │       └── pages/
│   │           └── analytics_page.dart
│   ├── reviews/                    # Reviews feature
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── reviews_page.dart
│   │       │   └── review_details_page.dart
│   │       └── providers/
│   │           └── review_provider.dart
│   ├── promotions/                 # Promotions feature
│   │   └── presentation/
│   │       └── pages/
│   │           └── promotions_page.dart
│   ├── categories/                 # Categories feature
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── categories_page.dart
│   │       └── providers/
│   │           └── category_provider.dart
│   ├── inventory/                  # Inventory feature
│   │   └── presentation/
│   │       └── pages/
│   │           └── inventory_page.dart
│   └── reports/                    # Reports feature
│       └── presentation/
│           └── pages/
│               └── reports_page.dart
├── shared/                         # Shared components
│   ├── widgets/                    # Reusable widgets
│   │   ├── custom_button.dart      # Custom button widget
│   │   ├── custom_text_field.dart  # Custom text field widget
│   │   ├── not_found_page.dart     # 404 page
│   │   ├── access_denied_page.dart # Access denied page
│   │   └── widgets.dart            # Widgets barrel file
│   ├── models/                     # Data models
│   │   └── user_model.dart         # User model
│   ├── services/                   # Shared services
│   │   ├── currency_provider.dart
│   │   ├── theme_provider.dart
│   │   ├── storage_service_provider.dart
│   │   └── role_service_provider.dart
│   └── shared.dart                 # Shared barrel file
└── routes/                         # Routing configuration
    ├── app_router.dart
    └── route_guards.dart
```

## 🏛️ Architecture Layers

### 1. **Presentation Layer** (`lib/features/{feature}/presentation/`)
- **Responsibility**: UI components, state management, user interactions
- **Components**: Pages, Widgets, Controllers, Providers
- **Dependencies**: Domain layer only

### 2. **Domain Layer** (`lib/features/{feature}/domain/`)
- **Responsibility**: Business logic, entities, use cases
- **Components**: Entities, Use Cases, Repository Interfaces
- **Dependencies**: None (pure business logic)

### 3. **Data Layer** (`lib/features/{feature}/data/`)
- **Responsibility**: Data operations, external dependencies
- **Components**: Repositories, Data Sources, Models
- **Dependencies**: Domain layer and Infrastructure layer

### 4. **Infrastructure Layer** (`lib/core/infrastructure/`)
- **Responsibility**: Firebase, APIs, external services
- **Components**: Firebase Services, API Clients, Storage
- **Dependencies**: External services only

## 🔄 Dependency Flow

```
Presentation → Domain ← Data → Infrastructure
```

## 📁 Feature Organization

### **Auth Feature** (`lib/features/auth/`)
- **Domain**: Authentication business logic
- **Data**: User data management
- **Presentation**: Login UI and auth state management

### **Dashboard Feature** (`lib/features/dashboard/`)
- **Domain**: Dashboard business logic
- **Data**: Dashboard data aggregation
- **Presentation**: Dashboard UI and analytics display

### **Products Feature** (`lib/features/products/`)
- **Domain**: Product management business logic
- **Data**: Product CRUD operations
- **Presentation**: Product listing, details, and management UI

### **Orders Feature** (`lib/features/orders/`)
- **Domain**: Order processing business logic
- **Data**: Order data management
- **Presentation**: Order listing, details, and management UI

### **Users Feature** (`lib/features/users/`)
- **Domain**: User management business logic
- **Data**: User CRUD operations
- **Presentation**: User listing, details, and management UI

### **Settings Feature** (`lib/features/settings/`)
- **Domain**: Settings business logic
- **Data**: Settings data management
- **Presentation**: Settings UI and configuration

## 🎯 Benefits

### **1. Modularity**
- Each feature is self-contained
- Easy to add, remove, or modify features
- Clear boundaries between features

### **2. Scalability**
- Easy to add new features
- Teams can work on different features independently
- Clear separation of concerns

### **3. Maintainability**
- Clear code organization
- Easy to locate and fix issues
- Consistent patterns across features

### **4. Testability**
- Each layer can be tested independently
- Clear dependencies make mocking easier
- Unit tests for business logic

### **5. Team Collaboration**
- Multiple developers can work on different features
- Clear ownership of code
- Reduced merge conflicts

## 🚀 Implementation Status

### ✅ **Completed**
- [x] Core directory structure
- [x] Feature-based organization
- [x] File migration to new structure
- [x] Barrel files for easy imports
- [x] Auth feature domain layer
- [x] Shared components organization

### 🔄 **In Progress**
- [ ] Update import statements
- [ ] Implement repository pattern
- [ ] Add comprehensive error handling
- [ ] Create unit tests

### 📋 **Future Enhancements**
- [ ] Add data layer implementations
- [ ] Implement dependency injection
- [ ] Add comprehensive documentation
- [ ] Performance optimization
- [ ] Add integration tests

## 📝 Naming Conventions

### **Files**
- Use `snake_case` for file names
- Use descriptive names that indicate purpose
- Group related files together

### **Classes**
- Use `PascalCase` for class names
- Use descriptive names
- Follow single responsibility principle

### **Directories**
- Use `snake_case` for directory names
- Use feature names for feature directories
- Use layer names for layer directories

## 🔧 Usage Examples

### **Importing Features**
```dart
// Import entire auth feature
import 'package:my_app/features/auth/auth.dart';

// Import specific auth components
import 'package:my_app/features/auth/presentation/pages/login_page.dart';
```

### **Importing Shared Components**
```dart
// Import shared components
import 'package:my_app/shared/shared.dart';

// Import specific shared components
import 'package:my_app/shared/widgets/custom_button.dart';
```

### **Importing Core Components**
```dart
// Import core components
import 'package:my_app/core/core.dart';

// Import specific core components
import 'package:my_app/core/constants/app_constants.dart';
```

This structure provides a solid foundation for a scalable, maintainable, and team-friendly Flutter application following clean architecture principles. 