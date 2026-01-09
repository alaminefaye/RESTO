import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirmation = true;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final result = await authService.register(
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      telephone: _telephoneController.text.trim(),
      email: _emailController.text.trim().isEmpty 
          ? null 
          : _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _passwordConfirmationController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (result['success'] == true) {
      // L'utilisateur est maintenant connecté, AuthWrapper redirigera automatiquement
      // Attendre un peu pour que le token soit bien sauvegardé
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
        // Forcer la mise à jour de AuthWrapper pour rediriger
        // La redirection se fera automatiquement via Consumer dans AuthWrapper
      }
    } else {
      String errorMessage = result['message'] ?? 'Erreur d\'inscription';
      
      // Nettoyer le message d'erreur pour l'utilisateur
      if (errorMessage.contains('DioException')) {
        errorMessage = 'Erreur de connexion au serveur. Vérifiez votre connexion internet.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 24),
                  
                  // Title
                  const Text(
                    'Créer un compte',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Inscrivez-vous pour continuer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Nom field
                  TextFormField(
                    controller: _nomController,
                    keyboardType: TextInputType.name,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nom *',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.person, color: Colors.orange),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre nom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Prénom field
                  TextFormField(
                    controller: _prenomController,
                    keyboardType: TextInputType.name,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Prénom *',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.orange),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre prénom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Téléphone field
                  TextFormField(
                    controller: _telephoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Téléphone *',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.phone, color: Colors.orange),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre numéro de téléphone';
                      }
                      if (value.length < 8) {
                        return 'Numéro de téléphone invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Email field (optional)
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email (optionnel)',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.email, color: Colors.orange),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty && !value.contains('@')) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Mot de passe *',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.lock, color: Colors.orange),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey[400],
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Password confirmation field
                  TextFormField(
                    controller: _passwordConfirmationController,
                    obscureText: _obscurePasswordConfirmation,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Confirmer le mot de passe *',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.orange),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePasswordConfirmation
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey[400],
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePasswordConfirmation = !_obscurePasswordConfirmation;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Register button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'S\'inscrire',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Vous avez déjà un compte ? ',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
