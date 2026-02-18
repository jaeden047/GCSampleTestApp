// api_service.dart imports only the switch file and uses PlatformTokenStore().
export 'token_store_mobile.dart'
  if (dart.library.html) 'token_store_web.dart';
  // “export A, unless condition is true, then export B.”