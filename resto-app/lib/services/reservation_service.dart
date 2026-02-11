import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/reservation.dart';
import 'api_service.dart';

class ReservationService {
  final ApiService _apiService = ApiService();

  // Récupérer toutes les réservations
  Future<List<Reservation>> getReservations({
    String? statut,
    String? date,
    bool? aVenir,
    int? tableId,
  }) async {
    try {
      String url = ApiConfig.reservations;
      Map<String, dynamic> queryParams = {};

      if (statut != null) queryParams['statut'] = statut;
      if (date != null) queryParams['date'] = date;
      if (aVenir != null) queryParams['a_venir'] = aVenir;
      if (tableId != null) queryParams['table_id'] = tableId;

      if (queryParams.isNotEmpty) {
        url += '?${Uri(queryParameters: queryParams).query}';
      }

      final response = await _apiService.get(url);
      if (response.statusCode == 200) {
        final data = response.data;
        List reservationsData;
        if (data is List) {
          reservationsData = data;
        } else if (data is Map && data['data'] != null) {
          reservationsData = data['data'] as List;
        } else {
          return [];
        }

        List<Reservation> reservations = [];
        for (var json in reservationsData) {
          try {
            if (json is Map<String, dynamic>) {
              final reservation = Reservation.fromJson(json);
              reservations.add(reservation);
            }
          } catch (_) {}
        }
        return reservations;
      }
      return [];
    } on DioException {
      return [];
    } catch (_) {
      return [];
    }
  }

  // Vérifier la disponibilité d'une table
  Future<Map<String, dynamic>> verifierDisponibilite({
    required int tableId,
    required DateTime dateReservation,
    required String heureDebut,
    required int duree,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.checkAvailability,
        data: {
          'table_id': tableId,
          'date_reservation': dateReservation.toIso8601String().split('T')[0],
          'heure_debut': heureDebut,
          'duree': duree,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': data['success'] ?? true,
          'disponible': data['disponible'] ?? false,
          'prix_total': data['prix_total'] != null
              ? (data['prix_total'] as num).toDouble()
              : null,
          'message': data['message'] ?? '',
        };
      }
      return {
        'success': false,
        'disponible': false,
        'message': 'Erreur lors de la vérification',
      };
    } on DioException catch (e) {
      String message = 'Erreur lors de la vérification de disponibilité';
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          message = data['message'] as String;
        }
      }
      return {'success': false, 'disponible': false, 'message': message};
    } catch (e) {
      return {
        'success': false,
        'disponible': false,
        'message': 'Erreur inattendue: ${e.toString()}',
      };
    }
  }

  // Créer une réservation
  Future<Map<String, dynamic>> createReservation({
    required int tableId,
    required String nomClient,
    required String telephone,
    required DateTime dateReservation,
    required String heureDebut,
    required int duree,
    required int nombrePersonnes,
    double? acompte,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.reservations,
        data: {
          'table_id': tableId,
          'nom_client': nomClient,
          'telephone': telephone,
          'date_reservation': dateReservation.toIso8601String().split('T')[0],
          'heure_debut': heureDebut,
          'duree': duree,
          'nombre_personnes': nombrePersonnes,
          if (acompte != null && acompte > 0) 'acompte': acompte,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        Map<String, dynamic> reservationData;
        if (data is Map) {
          reservationData = data.containsKey('data')
              ? data['data'] as Map<String, dynamic>
              : data as Map<String, dynamic>;
        } else {
          return {'success': false, 'message': 'Format de réponse invalide'};
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Réservation créée avec succès',
          'reservation': Reservation.fromJson(reservationData),
        };
      }
      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de la création',
      };
    } on DioException catch (e) {
      String message = 'Erreur lors de la création de la réservation';
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          message = data['message'] as String;
        } else if (data is Map && data['errors'] != null) {
          final errors = data['errors'] as Map;
          if (errors.isNotEmpty) {
            message = (errors.values.first as List).first as String;
          }
        }
        if (e.response?.statusCode == 422) {
          message = message;
        } else if (e.response?.statusCode == 400) {
          message = data['message'] ?? 'La table n\'est pas disponible';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        message =
            'Délai d\'attente dépassé. Vérifiez votre connexion internet.';
      } else if (e.type == DioExceptionType.connectionError) {
        message =
            'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur inattendue: ${e.toString()}',
      };
    }
  }

  // Récupérer une réservation par ID
  Future<Reservation?> getReservation(int id) async {
    try {
      final response = await _apiService.get('${ApiConfig.reservations}/$id');
      if (response.statusCode == 200) {
        final data = response.data;
        Map<String, dynamic> reservationData;
        if (data is Map) {
          if (data.containsKey('success') &&
              data['success'] == true &&
              data.containsKey('data')) {
            reservationData = data['data'] as Map<String, dynamic>;
          } else if (data.containsKey('data')) {
            reservationData = data['data'] as Map<String, dynamic>;
          } else {
            reservationData = data as Map<String, dynamic>;
          }
        } else {
          throw Exception('Format de données invalide');
        }
        return Reservation.fromJson(reservationData);
      }
      return null;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        final data = e.response?.data as Map;
        if (data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception('Erreur de connexion: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  // Confirmer une réservation
  Future<Map<String, dynamic>> confirmerReservation(int id) async {
    try {
      final response = await _apiService.patch(
        ApiConfig.confirmReservation(id),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': true,
          'message': data['message'] ?? 'Réservation confirmée avec succès',
        };
      }
      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de la confirmation',
      };
    } on DioException catch (e) {
      String message = 'Erreur lors de la confirmation';
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          message = data['message'] as String;
        }
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur inattendue: ${e.toString()}',
      };
    }
  }

  // Annuler une réservation
  Future<Map<String, dynamic>> annulerReservation(int id) async {
    try {
      final response = await _apiService.patch(ApiConfig.cancelReservation(id));

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': true,
          'message': data['message'] ?? 'Réservation annulée avec succès',
        };
      }
      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de l\'annulation',
      };
    } on DioException catch (e) {
      String message = 'Erreur lors de l\'annulation';
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          message = data['message'] as String;
        }
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur inattendue: ${e.toString()}',
      };
    }
  }
}
