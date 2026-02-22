import 'dart:async';
import 'package:flutter/material.dart';
import 'farmacos_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {

  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loaderController;

  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _loaderOpacity;

  @override
  void initState() {
    super.initState();

    // CONTROLADOR LOGO (fade-in)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // CONTROLADOR TEXTO (fade-in)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    // CONTROLADOR LOADER (fade-in suave)
    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loaderOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _loaderController, curve: Curves.easeIn),
    );

    // SECUENCIA DE ANIMACIONES
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 900), () {
      _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      _loaderController.forward();
    });

    // DURACIÓN TOTAL DEL SPLASH (4.5 s)
    Timer(const Duration(milliseconds: 4500), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, __, ___) => const FarmacosPage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // LOGO CON FADE-IN
              FadeTransition(
                opacity: _logoOpacity,
                child: Image.asset(
                  'assets/logos/sermas.png',
                  height: 120,
                ),
              ),

              const SizedBox(height: 40),

              // TEXTO AUTORES CON FADE-IN
              FadeTransition(
                opacity: _textOpacity,
                child: const Text(
                  "Autores:\n"
                  "Siles F; Montalbán D; Jaime G; Mejía R A; Ramos R; Gómez N; Cano S; de la Flor M;\n"
                  "Servicio de Anestesia y Reanimación.\n"
                  "Hospital Universitario Severo Ochoa. Mayo 2025.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // LOADER CON FADE-IN SUAVE
              FadeTransition(
                opacity: _loaderOpacity,
                child: const CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
