const serverDomainName = '192.168.213.5:8000'; //  Point d'acces android Tecno
// const serverDomainName = '192.168.2.9:3002'; //  WIFI stage

const String appProtocol = "http";






//Category Routes
const getAllCategoryRoute = "/category/getAll";

// Product routes
const createProductRoute = "/article/getByCategory";

// Article Routes
const getArticlesByCategoryRoute = "/article/getByCategory";
const getRecentArticlesRoute = "/article/getRecent";
const getPopularArticleRoute = "/article/getPopular";
const getSellerArticlesByIdRoute = "/article/getBySellerId";
const getArticlesByShopIdRoute = "/article/getByShopId";


// BasketArticle Routes
const getPopularBasketArticleRoute = "/basket-article/getPopular";

// UserRoute
const getOneUserDataByIdRoute = "/user";
const userCreateAccountRoute = "/user/create";


// SellerRoute
// const getSellerArticlesByIdRoute = "/article/getBySellerId";


// BasketRoute
const createBasketRoute = "/basket/create";

// CategoryRoute
const createCategoryRoute = "/category/create";

// Payment Method Route
const getAllPaymentMethodRoute = "/payment-method/getAll";
const createPaymentMethodRoute = "/payment-method/create";


const String testToken =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6OCwicm9sZSI6InVzZXIiLCJpYXQiO"
    "jE2OTIwNjkzMTksImV4cCI6MzYwMDAwMTY5MjA2OTMxOX0.MaSz3cXzVFRkshtH1Zq0-b7YL5e3K_R05ZoXnr2Z5CE";
