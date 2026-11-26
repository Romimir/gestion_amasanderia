import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get usuarioActual => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  //Detecta el nombre del empleado que ha iniciado sesión - si no tiene nombre registrado en supabase pasara a llamarse "Empleado"
  String get nombreEmpleado {
  final meta = usuarioActual?.userMetadata;
  return (meta?['full_name'] ?? meta?['name'] ?? 'Empleado') as String;
}

  //Método para inicio de sesión (solo cuentas añadidas previamente en Supabase)
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return true;
    } on AuthException catch (e) {
      if (e.message.contains('Inicio de sesión fallido')) {
        _errorMessage = 'Correo o contraseña incorrectos.';
      } else {
        _errorMessage = e.message;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Error de conexión. Verifica tu acceso a internet.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    notifyListeners();
  }
}