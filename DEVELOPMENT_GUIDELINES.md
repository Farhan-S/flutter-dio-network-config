# Development Guidelines - Flutter Dio Network Config Template

This guide provides step-by-step instructions for common development tasks in this Flutter template. Follow these guidelines to maintain consistency with the Clean Architecture pattern and BLoC state management.

---

## 📋 Table of Contents

- [Creating a New Feature](#creating-a-new-feature)
- [Implementing Data Fetching](#implementing-data-fetching)
- [Managing State with BLoC](#managing-state-with-bloc)
- [Creating New Pages](#creating-new-pages)
- [Adding New Routes](#adding-new-routes)
- [Error Handling](#error-handling)
- [Working with Storage](#working-with-storage)
- [Testing](#testing)
- [Best Practices](#best-practices)

---

## 🎯 Creating a New Feature

Follow these steps to create a new feature module (e.g., `products`):

### Step 1: Create Package Structure

```bash
mkdir -p packages/features_products/lib/{domain,data,presentation}
cd packages/features_products
```

### Step 2: Create pubspec.yaml

```yaml
# packages/features_products/pubspec.yaml
name: features_products
description: Products feature module
version: 1.0.0+1
publish_to: "none"

environment:
  sdk: ^3.9.2

dependencies:
  flutter:
    sdk: flutter

  # Core package (shared utilities)
  core:
    path: ../core

  # User package (if you need user entity)
  features_user:
    path: ../features_user

  # State management
  flutter_bloc: ^8.1.6
  bloc: ^8.1.4
  equatable: ^2.0.7

  # Functional programming
  dartz: ^0.10.1

dev_dependencies:
  flutter_test:
    sdk: flutter
```

### Step 3: Create Domain Layer

#### 3.1 Create Entity

```dart
// packages/features_products/lib/domain/entities/product_entity.dart
import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final DateTime createdAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, description, price, imageUrl, createdAt];
}
```

#### 3.2 Create Repository Interface

```dart
// packages/features_products/lib/domain/repositories/product_repository.dart
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  /// Get all products
  Future<Either<ApiException, List<ProductEntity>>> getProducts();

  /// Get product by ID
  Future<Either<ApiException, ProductEntity>> getProductById(String id);

  /// Create new product
  Future<Either<ApiException, ProductEntity>> createProduct({
    required String name,
    required String description,
    required double price,
    String? imageUrl,
  });

  /// Update existing product
  Future<Either<ApiException, ProductEntity>> updateProduct(
    String id, {
    String? name,
    String? description,
    double? price,
    String? imageUrl,
  });

  /// Delete product
  Future<Either<ApiException, void>> deleteProduct(String id);
}
```

#### 3.3 Create Use Cases

```dart
// packages/features_products/lib/domain/usecases/get_products_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<ApiException, List<ProductEntity>>> call() {
    return repository.getProducts();
  }
}
```

```dart
// packages/features_products/lib/domain/usecases/get_product_by_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductByIdUseCase {
  final ProductRepository repository;

  GetProductByIdUseCase(this.repository);

  Future<Either<ApiException, ProductEntity>> call(String id) {
    return repository.getProductById(id);
  }
}
```

### Step 4: Create Data Layer

#### 4.1 Create Model

```dart
// packages/features_products/lib/data/models/product_model.dart
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    super.imageUrl,
    required super.createdAt,
  });

  /// Convert entity to model
  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      imageUrl: entity.imageUrl,
      createdAt: entity.createdAt,
    );
  }

  /// Parse from JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert model to entity
  ProductEntity toEntity() => this;
}
```

#### 4.2 Create Data Source

```dart
// packages/features_products/lib/data/datasources/product_remote_datasource.dart
import 'package:core/core.dart';
import '../models/product_model.dart';

class ProductRemoteDataSource {
  final DioClient dioClient;

  ProductRemoteDataSource(this.dioClient);

  /// Get all products
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await dioClient.get(ApiRoutes.products);

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      rethrow; // Let interceptor handle error conversion
    }
  }

  /// Get product by ID
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await dioClient.get(ApiRoutes.productById(id));
      return ProductModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Create product
  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.products,
        data: data,
      );
      return ProductModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update product
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      final response = await dioClient.put(
        ApiRoutes.productById(id),
        data: data,
      );
      return ProductModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete product
  Future<void> deleteProduct(String id) async {
    try {
      await dioClient.delete(ApiRoutes.productById(id));
    } catch (e) {
      rethrow;
    }
  }
}
```

#### 4.3 Create Repository Implementation

```dart
// packages/features_products/lib/data/repositories/product_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<ApiException, List<ProductEntity>>> getProducts() async {
    try {
      final products = await remoteDataSource.getProducts();
      return Right(products.map((model) => model.toEntity()).toList());
    } on ApiException catch (e) {
      return Left(e);
    } catch (e, stackTrace) {
      return Left(UnknownException('Failed to get products', e, stackTrace));
    }
  }

  @override
  Future<Either<ApiException, ProductEntity>> getProductById(String id) async {
    try {
      final product = await remoteDataSource.getProductById(id);
      return Right(product.toEntity());
    } on ApiException catch (e) {
      return Left(e);
    } catch (e, stackTrace) {
      return Left(UnknownException('Failed to get product', e, stackTrace));
    }
  }

  @override
  Future<Either<ApiException, ProductEntity>> createProduct({
    required String name,
    required String description,
    required double price,
    String? imageUrl,
  }) async {
    try {
      final data = {
        'name': name,
        'description': description,
        'price': price,
        if (imageUrl != null) 'image_url': imageUrl,
      };

      final product = await remoteDataSource.createProduct(data);
      return Right(product.toEntity());
    } on ApiException catch (e) {
      return Left(e);
    } catch (e, stackTrace) {
      return Left(UnknownException('Failed to create product', e, stackTrace));
    }
  }

  @override
  Future<Either<ApiException, ProductEntity>> updateProduct(
    String id, {
    String? name,
    String? description,
    double? price,
    String? imageUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (price != null) data['price'] = price;
      if (imageUrl != null) data['image_url'] = imageUrl;

      final product = await remoteDataSource.updateProduct(id, data);
      return Right(product.toEntity());
    } on ApiException catch (e) {
      return Left(e);
    } catch (e, stackTrace) {
      return Left(UnknownException('Failed to update product', e, stackTrace));
    }
  }

  @override
  Future<Either<ApiException, void>> deleteProduct(String id) async {
    try {
      await remoteDataSource.deleteProduct(id);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e);
    } catch (e, stackTrace) {
      return Left(UnknownException('Failed to delete product', e, stackTrace));
    }
  }
}
```

### Step 5: Create Presentation Layer

#### 5.1 Create BLoC Events

```dart
// packages/features_products/lib/presentation/bloc/product_event.dart
import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductsEvent extends ProductEvent {
  const LoadProductsEvent();
}

class LoadProductByIdEvent extends ProductEvent {
  final String productId;

  const LoadProductByIdEvent(this.productId);

  @override
  List<Object> get props => [productId];
}

class CreateProductEvent extends ProductEvent {
  final String name;
  final String description;
  final double price;
  final String? imageUrl;

  const CreateProductEvent({
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, description, price, imageUrl];
}

class DeleteProductEvent extends ProductEvent {
  final String productId;

  const DeleteProductEvent(this.productId);

  @override
  List<Object> get props => [productId];
}
```

#### 5.2 Create BLoC States

```dart
// packages/features_products/lib/presentation/bloc/product_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductsLoaded extends ProductState {
  final List<ProductEntity> products;

  const ProductsLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class ProductLoaded extends ProductState {
  final ProductEntity product;

  const ProductLoaded(this.product);

  @override
  List<Object> get props => [product];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}

class ProductCreated extends ProductState {
  final ProductEntity product;

  const ProductCreated(this.product);

  @override
  List<Object> get props => [product];
}

class ProductDeleted extends ProductState {
  const ProductDeleted();
}
```

#### 5.3 Create BLoC

```dart
// packages/features_products/lib/presentation/bloc/product_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/get_product_by_id_usecase.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final GetProductByIdUseCase getProductByIdUseCase;

  ProductBloc({
    required this.getProductsUseCase,
    required this.getProductByIdUseCase,
  }) : super(const ProductInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<LoadProductByIdEvent>(_onLoadProductById);
  }

  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await getProductsUseCase();

    result.fold(
      (error) => emit(ProductError(error.message)),
      (products) => emit(ProductsLoaded(products)),
    );
  }

  Future<void> _onLoadProductById(
    LoadProductByIdEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await getProductByIdUseCase(event.productId);

    result.fold(
      (error) => emit(ProductError(error.message)),
      (product) => emit(ProductLoaded(product)),
    );
  }
}
```

### Step 6: Create Barrel Export File

```dart
// packages/features_products/lib/features_products.dart
library features_products;

// Domain
export 'domain/entities/product_entity.dart';
export 'domain/repositories/product_repository.dart';
export 'domain/usecases/get_products_usecase.dart';
export 'domain/usecases/get_product_by_id_usecase.dart';

// Data
export 'data/models/product_model.dart';
export 'data/datasources/product_remote_datasource.dart';
export 'data/repositories/product_repository_impl.dart';

// Presentation
export 'presentation/bloc/product_bloc.dart';
export 'presentation/bloc/product_event.dart';
export 'presentation/bloc/product_state.dart';
```

### Step 7: Register in Dependency Injection

```dart
// packages/app/lib/injection_container.dart

// Add to imports
import 'package:features_products/features_products.dart';

// Add to setupDependencyInjection()

// ==================== Features Products ====================

// Data Sources
getIt.registerLazySingleton<ProductRemoteDataSource>(
  () => ProductRemoteDataSource(getIt<DioClient>()),
);

// Repositories
getIt.registerLazySingleton<ProductRepository>(
  () => ProductRepositoryImpl(getIt<ProductRemoteDataSource>()),
);

// Use Cases
getIt.registerLazySingleton<GetProductsUseCase>(
  () => GetProductsUseCase(getIt<ProductRepository>()),
);

getIt.registerLazySingleton<GetProductByIdUseCase>(
  () => GetProductByIdUseCase(getIt<ProductRepository>()),
);

// BLoC - Use factory for page-specific state
getIt.registerFactory<ProductBloc>(
  () => ProductBloc(
    getProductsUseCase: getIt<GetProductsUseCase>(),
    getProductByIdUseCase: getIt<GetProductByIdUseCase>(),
  ),
);
```

### Step 8: Add API Routes

```dart
// packages/core/lib/src/routes/api_routes.dart

class ApiRoutes {
  // ... existing routes

  // Product routes
  static const String products = '/products';
  static String productById(dynamic id) => '/products/$id';
}
```

---

## 📡 Implementing Data Fetching

### Simple GET Request

```dart
// In DataSource
Future<List<ProductModel>> getProducts() async {
  final response = await dioClient.get(ApiRoutes.products);
  final List<dynamic> data = response.data as List<dynamic>;
  return data.map((json) => ProductModel.fromJson(json)).toList();
}
```

### GET with Query Parameters

```dart
Future<List<ProductModel>> searchProducts(String query) async {
  final response = await dioClient.get(
    ApiRoutes.products,
    queryParameters: {
      'search': query,
      'limit': 20,
      'sort': 'name',
    },
  );
  final List<dynamic> data = response.data as List<dynamic>;
  return data.map((json) => ProductModel.fromJson(json)).toList();
}
```

### POST Request with Body

```dart
Future<ProductModel> createProduct(Map<String, dynamic> data) async {
  final response = await dioClient.post(
    ApiRoutes.products,
    data: data,
  );
  return ProductModel.fromJson(response.data);
}
```

### PUT/PATCH Request

```dart
Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) async {
  final response = await dioClient.put(
    ApiRoutes.productById(id),
    data: data,
  );
  return ProductModel.fromJson(response.data);
}
```

### DELETE Request

```dart
Future<void> deleteProduct(String id) async {
  await dioClient.delete(ApiRoutes.productById(id));
}
```

### File Upload

```dart
Future<ProductModel> uploadProductImage(String productId, String filePath) async {
  final response = await dioClient.uploadFile(
    ApiRoutes.productImage(productId),
    filePath: filePath,
    fileKey: 'image',
    additionalData: {
      'product_id': productId,
      'description': 'Product image',
    },
  );
  return ProductModel.fromJson(response.data);
}
```

### File Download

```dart
Future<void> downloadProductCatalog(String savePath) async {
  await dioClient.downloadFile(
    ApiRoutes.productCatalog,
    savePath,
    onReceiveProgress: (received, total) {
      final progress = (received / total * 100).toStringAsFixed(0);
      print('Download progress: $progress%');
    },
  );
}
```

---

## 🎭 Managing State with BLoC

### Basic BLoC Pattern

#### 1. Define Events

```dart
abstract class ProductEvent extends Equatable {
  const ProductEvent();
}

class LoadProductsEvent extends ProductEvent {
  const LoadProductsEvent();

  @override
  List<Object> get props => [];
}
```

#### 2. Define States

```dart
abstract class ProductState extends Equatable {
  const ProductState();
}

class ProductInitial extends ProductState {
  @override
  List<Object> get props => [];
}

class ProductLoading extends ProductState {
  @override
  List<Object> get props => [];
}

class ProductsLoaded extends ProductState {
  final List<ProductEntity> products;

  const ProductsLoaded(this.products);

  @override
  List<Object> get props => [products];
}
```

#### 3. Implement BLoC

```dart
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;

  ProductBloc({required this.getProductsUseCase})
      : super(const ProductInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
  }

  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await getProductsUseCase();

    result.fold(
      (error) => emit(ProductError(error.message)),
      (products) => emit(ProductsLoaded(products)),
    );
  }
}
```

### Using BLoC in UI

#### BlocProvider (Page Level)

```dart
class ProductsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductBloc>()..add(const LoadProductsEvent()),
      child: ProductsView(),
    );
  }
}
```

#### BlocBuilder (Reactive UI)

```dart
class ProductsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProductError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is ProductsLoaded) {
          return ListView.builder(
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              return ProductCard(product: product);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
```

#### BlocListener (Side Effects)

```dart
BlocListener<ProductBloc, ProductState>(
  listener: (context, state) {
    if (state is ProductCreated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product created successfully!')),
      );
      context.read<ProductBloc>().add(const LoadProductsEvent());
    }

    if (state is ProductError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  child: ProductForm(),
)
```

#### BlocConsumer (Builder + Listener)

```dart
BlocConsumer<ProductBloc, ProductState>(
  listener: (context, state) {
    // Handle side effects
    if (state is ProductDeleted) {
      Navigator.pop(context);
    }
  },
  builder: (context, state) {
    // Build UI based on state
    if (state is ProductLoading) {
      return const CircularProgressIndicator();
    }
    return ProductDetails(product: state.product);
  },
)
```

### Dispatching Events

```dart
// From UI
ElevatedButton(
  onPressed: () {
    context.read<ProductBloc>().add(
      CreateProductEvent(
        name: nameController.text,
        description: descController.text,
        price: double.parse(priceController.text),
      ),
    );
  },
  child: const Text('Create Product'),
)
```

---

## 📄 Creating New Pages

### Step 1: Create Page File

```dart
// packages/features_products/lib/presentation/pages/products_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import '../../injection_container.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_list.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductBloc>()..add(const LoadProductsEvent()),
      child: const ProductsView(),
    );
  }
}

class ProductsView extends StatelessWidget {
  const ProductsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => AppRoutes.goToCreateProduct(context),
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductBloc>().add(const LoadProductsEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ProductsLoaded) {
            if (state.products.isEmpty) {
              return const Center(
                child: Text('No products found'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductBloc>().add(const LoadProductsEvent());
              },
              child: ProductList(products: state.products),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

### Step 2: Create Widgets

```dart
// packages/features_products/lib/presentation/widgets/product_list.dart
import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';
import 'product_card.dart';

class ProductList extends StatelessWidget {
  final List<ProductEntity> products;

  const ProductList({
    Key? key,
    required this.products,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}
```

```dart
// packages/features_products/lib/presentation/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:core/core.dart';
import '../../domain/entities/product_entity.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;

  const ProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: product.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image),
                ),
              )
            : const Icon(Icons.shopping_bag, size: 40),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          product.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        onTap: () => AppRoutes.goToProductDetail(context, product.id),
      ),
    );
  }
}
```

---

## 🧭 Adding New Routes

### Step 1: Add Route Constants

```dart
// packages/core/lib/src/routes/app_routes.dart

class AppRoutes {
  // ... existing routes

  // Product routes
  static const String products = 'products';
  static const String productDetail = 'product-detail';
  static const String createProduct = 'create-product';

  static const String productsPath = '/products';
  static const String productDetailPath = '/products/:productId';
  static const String createProductPath = '/products/create';

  // Route parameters
  static const String productIdParam = 'productId';

  // Navigation helpers
  static void goToProducts(BuildContext context) {
    context.go(productsPath);
  }

  static void goToProductDetail(BuildContext context, String productId) {
    context.go('/products/$productId');
  }

  static void goToCreateProduct(BuildContext context) {
    context.go(createProductPath);
  }
}
```

### Step 2: Register Routes in Router

```dart
// packages/app/lib/routes/app_router.dart

GoRoute(
  path: AppRoutes.productsPath,
  name: AppRoutes.products,
  pageBuilder: (context, state) => _buildPageWithTransition(
    key: state.pageKey,
    child: BlocProvider(
      create: (_) => getIt<ProductBloc>(),
      child: const ProductsPage(),
    ),
  ),
  routes: [
    // Product detail as sub-route
    GoRoute(
      path: ':${AppRoutes.productIdParam}',
      name: AppRoutes.productDetail,
      pageBuilder: (context, state) {
        final productId = state.pathParameters[AppRoutes.productIdParam]!;
        return _buildPageWithTransition(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => getIt<ProductBloc>()
              ..add(LoadProductByIdEvent(productId)),
            child: const ProductDetailPage(),
          ),
        );
      },
    ),

    // Create product as sub-route
    GoRoute(
      path: 'create',
      name: AppRoutes.createProduct,
      pageBuilder: (context, state) => _buildPageWithTransition(
        key: state.pageKey,
        child: BlocProvider(
          create: (_) => getIt<ProductBloc>(),
          child: const CreateProductPage(),
        ),
      ),
    ),
  ],
),
```

### Step 3: Use Navigation

```dart
// Navigate to products list
AppRoutes.goToProducts(context);

// Navigate to product detail
AppRoutes.goToProductDetail(context, '123');

// Navigate with context.go
context.go('/products/123');

// Navigate with context.push (keeps previous route in stack)
context.push('/products/create');

// Pop back
context.pop();

// Replace current route
context.replace('/products');
```

---

## ⚠️ Error Handling

### Handling Errors in Repository

```dart
@override
Future<Either<ApiException, ProductEntity>> getProductById(String id) async {
  try {
    final product = await remoteDataSource.getProductById(id);
    return Right(product.toEntity());
  } on NotFoundException catch (e) {
    // Handle specific 404 error
    return Left(e);
  } on UnauthorizedException catch (e) {
    // Handle 401 error
    return Left(e);
  } on ApiException catch (e) {
    // Handle other API exceptions
    return Left(e);
  } catch (e, stackTrace) {
    // Handle unexpected errors
    return Left(UnknownException('Failed to get product', e, stackTrace));
  }
}
```

### Displaying Errors in UI

```dart
BlocBuilder<ProductBloc, ProductState>(
  builder: (context, state) {
    if (state is ProductError) {
      return ErrorWidget(
        message: state.message,
        onRetry: () {
          context.read<ProductBloc>().add(const LoadProductsEvent());
        },
      );
    }

    // ... other states
  },
)
```

### Custom Error Widget

```dart
class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## 💾 Working with Storage

### Saving Data to SharedPreferences

```dart
// packages/core/lib/src/storage/product_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class ProductStorage {
  final SharedPreferences _prefs;
  static const String _favoriteProductsKey = 'favorite_products';

  ProductStorage(this._prefs);

  Future<void> saveFavoriteProduct(String productId) async {
    final favorites = await getFavoriteProducts();
    if (!favorites.contains(productId)) {
      favorites.add(productId);
      await _prefs.setStringList(_favoriteProductsKey, favorites);
    }
  }

  Future<void> removeFavoriteProduct(String productId) async {
    final favorites = await getFavoriteProducts();
    favorites.remove(productId);
    await _prefs.setStringList(_favoriteProductsKey, favorites);
  }

  Future<List<String>> getFavoriteProducts() async {
    return _prefs.getStringList(_favoriteProductsKey) ?? [];
  }

  Future<bool> isFavorite(String productId) async {
    final favorites = await getFavoriteProducts();
    return favorites.contains(productId);
  }
}
```

### Saving Sensitive Data to Secure Storage

```dart
// For sensitive data like tokens, credentials
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureProductStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: 'product_api_key', value: apiKey);
  }

  Future<String?> getApiKey() async {
    return await _storage.read(key: 'product_api_key');
  }

  Future<void> deleteApiKey() async {
    await _storage.delete(key: 'product_api_key');
  }
}
```

---

## 🧪 Testing

### Unit Test - Use Case

```dart
// test/domain/usecases/get_products_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late GetProductsUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProductsUseCase(mockRepository);
  });

  test('should get products from repository', () async {
    // Arrange
    final products = [
      ProductEntity(
        id: '1',
        name: 'Test Product',
        description: 'Description',
        price: 99.99,
        createdAt: DateTime.now(),
      ),
    ];
    when(() => mockRepository.getProducts())
        .thenAnswer((_) async => Right(products));

    // Act
    final result = await useCase();

    // Assert
    expect(result, Right(products));
    verify(() => mockRepository.getProducts()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
```

### BLoC Test

```dart
// test/presentation/bloc/product_bloc_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

void main() {
  late ProductBloc bloc;
  late MockGetProductsUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetProductsUseCase();
    bloc = ProductBloc(getProductsUseCase: mockUseCase);
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state is ProductInitial', () {
    expect(bloc.state, const ProductInitial());
  });

  blocTest<ProductBloc, ProductState>(
    'emits [ProductLoading, ProductsLoaded] when LoadProductsEvent succeeds',
    build: () {
      when(() => mockUseCase()).thenAnswer(
        (_) async => Right([
          ProductEntity(
            id: '1',
            name: 'Test',
            description: 'Desc',
            price: 99,
            createdAt: DateTime.now(),
          ),
        ]),
      );
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadProductsEvent()),
    expect: () => [
      const ProductLoading(),
      isA<ProductsLoaded>(),
    ],
    verify: (_) {
      verify(() => mockUseCase()).called(1);
    },
  );

  blocTest<ProductBloc, ProductState>(
    'emits [ProductLoading, ProductError] when LoadProductsEvent fails',
    build: () {
      when(() => mockUseCase()).thenAnswer(
        (_) async => Left(NetworkException('Network error', null, null)),
      );
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadProductsEvent()),
    expect: () => [
      const ProductLoading(),
      const ProductError('Network error'),
    ],
  );
}
```

### Widget Test

```dart
// test/presentation/pages/products_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockProductBloc extends MockBloc<ProductEvent, ProductState>
    implements ProductBloc {}

void main() {
  late MockProductBloc mockBloc;

  setUp(() {
    mockBloc = MockProductBloc();
  });

  testWidgets('shows loading indicator when state is ProductLoading',
      (tester) async {
    when(() => mockBloc.state).thenReturn(const ProductLoading());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProductBloc>.value(
          value: mockBloc,
          child: const ProductsPage(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows products list when state is ProductsLoaded',
      (tester) async {
    final products = [
      ProductEntity(
        id: '1',
        name: 'Test Product',
        description: 'Description',
        price: 99.99,
        createdAt: DateTime.now(),
      ),
    ];

    when(() => mockBloc.state).thenReturn(ProductsLoaded(products));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProductBloc>.value(
          value: mockBloc,
          child: const ProductsPage(),
        ),
      ),
    );

    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
  });
}
```

---

## ✅ Best Practices

### 1. **Follow Clean Architecture Layers**

- Domain layer: No Flutter/Dart dependencies
- Data layer: Only depend on domain interfaces
- Presentation layer: Only depend on domain layer

### 2. **Use Proper Naming Conventions**

- Entities: `ProductEntity`, `UserEntity`
- Models: `ProductModel`, `UserModel`
- Repositories: `ProductRepository`, `UserRepository`
- Use Cases: `GetProductsUseCase`, `CreateProductUseCase`
- BLoCs: `ProductBloc`, `AuthBloc`
- Events: `LoadProductsEvent`, `CreateProductEvent`
- States: `ProductsLoaded`, `ProductError`

### 3. **State Management**

- Use **LazySingleton** for persistent BLoCs (Auth, Theme, Localization)
- Use **Factory** for page-specific BLoCs
- Always dispose BLoCs when not using singleton

### 4. **Error Handling**

- Always catch and convert exceptions in repositories
- Use `Either<ApiException, T>` for all repository methods
- Display user-friendly error messages in UI

### 5. **Testing**

- Write unit tests for use cases
- Write BLoC tests using bloc_test
- Write widget tests for critical UI components

### 6. **Code Organization**

- One file per class
- Use barrel exports (`features_products.dart`)
- Keep files focused and small (<300 lines)

### 7. **API Integration**

- Define all routes in `ApiRoutes`
- Use DioClient methods instead of raw Dio
- Let interceptors handle errors and auth

### 8. **Performance**

- Use `const` constructors where possible
- Lazy load features with factory registration
- Cache network responses when appropriate

### 9. **Security**

- Never commit API keys or secrets
- Use FlutterSecureStorage for sensitive data
- Always use HTTPS for API calls

### 10. **Documentation**

- Document complex business logic
- Add comments for non-obvious code
- Update README when adding major features

---

## 📚 Additional Resources

- [BLoC Library Documentation](https://bloclibrary.dev/)
- [Dio Documentation](https://pub.dev/packages/dio)
- [go_router Documentation](https://pub.dev/packages/go_router)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

**Happy Coding! 🚀**
