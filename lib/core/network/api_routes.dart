/// Centralized API routes management
class ApiRoutes {
  // API version prefix
  static const String v1 = '/api/v1';
  
  // Auth endpoints
  static const String login = '$v1/auth/login';
  static const String register = '$v1/auth/register';
  static const String logout = '$v1/auth/logout';
  static const String refreshToken = '$v1/auth/refresh';
  static const String forgotPassword = '$v1/auth/forgot-password';
  static const String resetPassword = '$v1/auth/reset-password';
  
  // User endpoints
  static const String getUser = '$v1/user';
  static const String updateUser = '$v1/user';
  static const String deleteUser = '$v1/user';
  static String userById(String id) => '$v1/user/$id';
  
  // File endpoints
  static const String uploadFile = '$v1/files/upload';
  static const String uploadMultiple = '$v1/files/upload/multiple';
  static String downloadFile(String id) => '$v1/files/download/$id';
  
  // Example of dynamic routes
  static String getPost(int id) => '$v1/posts/$id';
  static String getUserPosts(String userId) => '$v1/users/$userId/posts';
  
  // You can add more endpoints as needed
  // static const String products = '$v1/products';
  // static String productById(String id) => '$v1/products/$id';
}
