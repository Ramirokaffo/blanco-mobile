// Conversions des réponses de l'API Django : DRF sérialise les DecimalField
// en chaînes ("1500.00") et les booléens en true/false.

double? toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? double.tryParse(value.toString())?.toInt();
}

bool toBool(dynamic value) {
  return value == true || value == 1 || value == "1" || value == "true";
}

/// Exception levée quand le serveur répond par une erreur ; [message] est le
/// texte renvoyé par Django (déjà traduit), affichable tel quel.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Extrait un message lisible d'une réponse d'erreur
/// ({"error": ...}, {"errors": {...}}, {"detail": ...}).
String extractErrorMessage(dynamic data, {String fallback = "Une erreur s'est produite"}) {
  if (data is Map) {
    if (data["error"] != null) return data["error"].toString();
    if (data["detail"] != null) return data["detail"].toString();
    final errors = data["errors"];
    if (errors != null) return _flattenErrors(errors) ?? fallback;
  }
  if (data is List && data.isNotEmpty) return _flattenErrors(data) ?? fallback;
  return fallback;
}

String? _flattenErrors(dynamic errors) {
  if (errors is String) return errors;
  if (errors is List) {
    final messages = errors.map(_flattenErrors).whereType<String>().toList();
    return messages.isEmpty ? null : messages.join("\n");
  }
  if (errors is Map) {
    final messages = errors.values.map(_flattenErrors).whereType<String>().toList();
    return messages.isEmpty ? null : messages.join("\n");
  }
  return errors?.toString();
}

/// Message à afficher pour une erreur quelconque remontée par un appel réseau.
String errorMessageOf(Object? error, {String fallback = "Une erreur s'est produite"}) {
  if (error is ApiException) return error.message;
  return fallback;
}
