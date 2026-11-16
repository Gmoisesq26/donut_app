import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rive/rive.dart';
import 'package:donut_app/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  // Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Estado de la pantalla
  bool _obscureText = true;
  bool _isLoading = false;

  // Controladores de Rive
  StateMachineController? _controller;
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _isTrigSuccess;
  SMITrigger? _isTrigFail;
  SMINumber? _numlook;

  // Timer para la animación
  Timer? _typingDebounce;

  // FocusNodes
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // Controladores de texto
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  // Errores
  String? emailError;
  String? passError;

  // Validar correo
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  // Validar contraseña para REGISTRO
  bool isValidPassword(String pass) {
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  // Mostrar mensajes
  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // Mensajes de Firebase
  String _firebaseErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'El correo electrónico no es válido.';

      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'Correo o contraseña incorrectos.';

      case 'email-already-in-use':
        return 'Este correo ya está registrado.';

      case 'weak-password':
        return 'La contraseña es demasiado débil.';

      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';

      case 'too-many-requests':
        return 'Demasiados intentos. Inténtalo más tarde.';

      case 'network-request-failed':
        return 'No se pudo conectar. Revisa tu conexión.';

      case 'operation-not-allowed':
        return 'El inicio de sesión con correo no está habilitado.';

      default:
        return error.message ?? 'Ocurrió un error de autenticación.';
    }
  }

  // Reiniciar animaciones
  void _resetRive() {
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numlook?.value = 50;
  }

  // Validar campos
  bool _validateFields({bool register = false}) {
    final email = emailController.text.trim();
    final password = passController.text;

    String? newEmailError;
    String? newPasswordError;

    if (email.isEmpty) {
      newEmailError = 'Ingresa tu correo electrónico';
    } else if (!isValidEmail(email)) {
      newEmailError = 'Correo electrónico inválido';
    }

    if (password.isEmpty) {
      newPasswordError = 'Ingresa tu contraseña';
    } else if (register && !isValidPassword(password)) {
      newPasswordError =
          'Usa 8 caracteres, mayúscula, minúscula, número y símbolo';
    }

    setState(() {
      emailError = newEmailError;
      passError = newPasswordError;
    });

    return newEmailError == null && newPasswordError == null;
  }

  // INICIAR SESIÓN
  Future<void> _onLogin() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();
    _resetRive();

    if (!_validateFields()) {
      _isTrigFail?.fire();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text,
      );

      if (!mounted) return;

      _isTrigSuccess?.fire();

      // No se necesita Navigator.
      // main.dart detectará el usuario mediante authStateChanges()
      // y mostrará HomePage automáticamente.
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      _isTrigFail?.fire();
      _showMessage(_firebaseErrorMessage(error));
    } catch (error) {
      if (!mounted) return;

      _isTrigFail?.fire();
      _showMessage('Ocurrió un error inesperado.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // REGISTRAR CUENTA
  Future<void> _register() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();
    _resetRive();

    if (!_validateFields(register: true)) {
      _isTrigFail?.fire();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text,
      );

      if (!mounted) return;

      _isTrigSuccess?.fire();

      _showMessage('¡Cuenta creada correctamente!');

      // Firebase inicia sesión automáticamente después del registro.
      // authStateChanges() mostrará HomePage desde main.dart.
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      _isTrigFail?.fire();
      _showMessage(_firebaseErrorMessage(error));
    } catch (error) {
      if (!mounted) return;

      _isTrigFail?.fire();
      _showMessage('No se pudo crear la cuenta.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // INICIAR SESIÓN CON GOOGLE
  Future<void> _onGoogleLogin() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();
    _resetRive();

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.signInWithGoogle();

      if (!mounted) return;

      // result == null significa que el usuario canceló el selector de cuentas
      if (result != null) {
        _isTrigSuccess?.fire();
      }

      // main.dart detecta el usuario con authStateChanges()
      // y muestra HomePage automáticamente.
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      _isTrigFail?.fire();
      _showMessage(_firebaseErrorMessage(error));
    } catch (error, stack) {
      if (!mounted) return;

      debugPrint('Error Google Sign-In: $error');
      debugPrint('$stack');
      _isTrigFail?.fire();
      _showMessage('Error: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // RECUPERAR CONTRASEÑA
  Future<void> _forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty || !isValidEmail(email)) {
      setState(() {
        emailError = 'Ingresa un correo válido para recuperar tu cuenta';
      });

      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      _showMessage(
        'Si existe una cuenta con ese correo, recibirás instrucciones para restablecer tu contraseña.',
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      _showMessage(_firebaseErrorMessage(error));
    } catch (error) {
      if (!mounted) return;

      _showMessage('No se pudo enviar el correo de recuperación.');
    }
  }

  // INICIALIZAR RIVE
  void _onRiveInit(Artboard artboard) {
    _controller = StateMachineController.fromArtboard(
      artboard,
      'Login Machine',
    );

    if (_controller == null) return;

    artboard.addController(_controller!);

    _isChecking = _controller!.findSMI('isChecking');
    _isHandsUp = _controller!.findSMI('isHandsUp');
    _isTrigSuccess = _controller!.findSMI('trigSuccess');
    _isTrigFail = _controller!.findSMI('trigFail');
    _numlook = _controller!.findSMI('numLook');
  }

  @override
  void initState() {
    super.initState();

    // Cuando el correo tiene el foco
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        _isHandsUp?.change(false);
        _numlook?.value = 50;
      }
    });

    // Cuando la contraseña tiene el foco
    _passwordFocusNode.addListener(() {
      _isHandsUp?.change(_passwordFocusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.top,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ANIMACIÓN RIVE
                SizedBox(
                  height: 200,
                  width: size.width,
                  child: RiveAnimation.asset(
                    'assets/login_bear.riv',
                    onInit: _onRiveInit,
                  ),
                ),

                const SizedBox(height: 20),

                // CORREO
                TextField(
                  focusNode: _emailFocusNode,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  onSubmitted: (_) {
                    _passwordFocusNode.requestFocus();
                  },
                  onChanged: (value) {
                    if (emailError != null) {
                      setState(() {
                        emailError = null;
                      });
                    }

                    _isChecking?.change(true);

                    final look =
                        (value.length / 80.0 * 100.0).clamp(0.0, 100.0);

                    _numlook?.value = look;

                    _typingDebounce?.cancel();

                    _typingDebounce = Timer(
                      const Duration(seconds: 3),
                      () {
                        if (!mounted) return;

                        _isChecking?.change(false);
                        _numlook?.value = 50;
                      },
                    );
                  },
                  decoration: InputDecoration(
                    errorText: emailError,
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // CONTRASEÑA
                TextField(
                  focusNode: _passwordFocusNode,
                  controller: passController,
                  obscureText: _obscureText,
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _onLogin(),
                  onChanged: (value) {
                    if (passError != null) {
                      setState(() {
                        passError = null;
                      });
                    }

                    _isChecking?.change(false);
                  },
                  decoration: InputDecoration(
                    errorText: passError,
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // RECUPERAR CONTRASEÑA
                SizedBox(
                  width: size.width,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _forgotPassword,
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // BOTÓN LOGIN
                SizedBox(
                  width: size.width,
                  height: 50,
                  child: MaterialButton(
                    color: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onPressed: _isLoading ? null : _onLogin,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                const SizedBox(height: 16),

                // SEPARADOR
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('o'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 16),

                // BOTÓN GOOGLE
                SizedBox(
                  width: size.width,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _onGoogleLogin,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'G',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Continuar con Google',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // REGISTRO
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: _isLoading ? null : _register,
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.underline,
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
    );
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    _typingDebounce?.cancel();

    emailController.dispose();
    passController.dispose();

    super.dispose();
  }
}
