# Maloc CLI

A command-line tool to generate feature packages with Clean Architecture for your Flutter project.

**Maloc** = **Melos** + **BLoC** - The perfect combination for modular Flutter development!

## ⚡ Quick Start

### 1. Bootstrap the workspace (first time only)

From the project root:

```bash
# Cross-platform (works on Windows, macOS, Linux)
dart bootstrap.dart

# Or use platform-specific scripts
./bootstrap.sh      # Linux/macOS
bootstrap.bat       # Windows
```

### 2. Install Maloc CLI

```bash
cd cli
dart pub global activate --source path .
```

### 3. Create features instantly

```bash
maloc create --name products
```

✨ **Everything is automated:**

- ✅ Creates Clean Architecture structure
- ✅ Installs feature dependencies
- ✅ Registers routes in app_routes.dart
- ✅ Registers routes in app_route_generator.dart

## Installation

### Option 1: Activate globally (Recommended)

```bash
cd cli
dart pub global activate --source path .
```

After activation, you can use `maloc` from anywhere:

```bash
maloc create --name products
```

### Option 2: Run from source

```bash
cd cli
dart pub get
dart run bin/maloc.dart create --name products
```

## Usage

### Create a new feature

```bash
maloc create --name products
```

Or using short option:

```bash
maloc create -n user_profile
```

### Show help

```bash
maloc --help
maloc create --help
```

### Show version

```bash
maloc --version
```

## What Gets Generated

When you run `maloc create --name products`, it creates:

```
packages/features_products/
├── lib/
│   ├── features_products.dart          # Barrel export file
│   ├── domain/
│   │   ├── entities/
│   │   │   └── products_entity.dart
│   │   ├── repositories/
│   │   │   └── products_repository.dart
│   │   └── usecases/
│   │       └── get_products_usecase.dart
│   ├── data/
│   │   ├── models/
│   │   │   └── products_model.dart
│   │   ├── datasources/
│   │   │   └── products_remote_datasource.dart
│   │   └── repositories/
│   │       └── products_repository_impl.dart
│   └── presentation/
│       ├── bloc/
│       │   ├── products_bloc.dart
│       │   ├── products_event.dart
│       │   └── products_state.dart
│       ├── pages/
│       │   └── products_page.dart
│       └── widgets/
└── pubspec.yaml
```

## Generated Files Include

- ✅ Complete Clean Architecture structure
- ✅ Domain layer (entities, repositories, use cases)
- ✅ Data layer (models, datasources, repository implementations)
- ✅ Presentation layer (BLoC with events/states, pages)
- ✅ Barrel export file
- ✅ pubspec.yaml with all dependencies
- ✅ Proper imports and boilerplate code
- ✅ **Automatic route registration** in app_routes.dart and app_route_generator.dart

## Automatic Route Registration

The CLI automatically:

1. **Adds route constant** to `core/lib/src/routes/app_routes.dart`:

   ```dart
   static const String products = '/products';
   ```

2. **Adds navigation helper** to `core/lib/src/routes/app_routes.dart`:

   ```dart
   static Future<void> navigateToProducts(BuildContext context) {
     return Navigator.pushNamed(context, products);
   }
   ```

3. **Registers route in switch statement** in `app/lib/routes/app_route_generator.dart`:

   ```dart
   case AppRoutes.products:
     return _createRoute(
       BlocProvider(
         create: (_) => getIt<ProductsBloc>(),
         child: const ProductsPage(),
       ),
       settings,
     );
   ```

4. **Registers in route registry** in `app/lib/routes/app_route_generator.dart`:
   ```dart
   AppRouteRegistry.registerRoute(
     AppRoutes.products,
     (settings) => MaterialPageRoute(
       builder: (_) => BlocProvider(
         create: (_) => getIt<ProductsBloc>(),
         child: const ProductsPage(),
       ),
       settings: settings,
     ),
   );
   ```

## Post-Generation Steps

After generating a feature, the CLI will show you the next steps:

1. Add dependency to `app/pubspec.yaml`
2. Register dependencies in `app/lib/injection_container.dart`
3. Run `flutter pub get`

✨ **Routes are automatically registered** - no manual route setup needed!

## Examples

```bash
# Create a products feature
maloc create --name products

# Create a user profile feature
maloc create --name user_profile

# Create a shopping cart feature
maloc create --name shopping_cart
```

## Naming Conventions

The CLI automatically handles naming:

- **snake_case**: File names, package names
- **PascalCase**: Class names
- **camelCase**: Variable names

Example: `user_profile` → `UserProfile` (class) → `userProfile` (variable)

## Uninstall

To remove the CLI:

```bash
dart pub global deactivate maloc
```

## License

MIT
