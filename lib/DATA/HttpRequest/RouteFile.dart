// Routes de l'API Django (core/api_urls.py). Toutes sont préfixées par /api/.

const String appProtocol = "http";

// Auth
const String loginRoute = "/api/auth/login/";

// Utilisateurs
const String createUserRoute = "/api/staff/";
String userByIdRoute(int id) => "/api/staff/$id/";
String updateUserRoute(int id) => "/api/staff/$id/update/";

// Produits
const String productListRoute = "/api/products/list/";
const String productSearchRoute = "/api/products/search/";
const String createProductRoute = "/api/products/";
String productByIdRoute(int id) => "/api/products/$id/";
String productByCodeRoute(String code) => "/api/products/by-code/${Uri.encodeComponent(code)}/";
String productByNameRoute(String name) => "/api/products/by-name/${Uri.encodeComponent(name)}/";
String updateProductRoute(int id) => "/api/products/$id/update/";
String imageRoute(String folder, String image) => "/api/images/$folder/${Uri.encodeComponent(image)}/";

// Données de référence
const String categoriesRoute = "/api/categories/";
const String rayonsRoute = "/api/rayons/";
const String gammesRoute = "/api/gammes/";
const String grammageTypesRoute = "/api/grammage-types/";

// Ventes
const String createSaleRoute = "/api/sales/";

// Inventaire
const String createInventoryRoute = "/api/inventory/";

// Utilitaires
const String testConnectionRoute = "/api/test-connection/";
