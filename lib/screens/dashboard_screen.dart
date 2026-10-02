import 'package:flutter/material.dart';
import 'package:gestion_amasanderia/screens/order_from_screen.dart';
import 'package:gestion_amasanderia/screens/order_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        title: const Text(
          'Gestión de Pedidos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo de la amasandería
                Image.asset(
                'lib/assets/icons/logo.png',
                height: 180,
                fit: BoxFit.contain,
                ),
              const SizedBox(height: 24),

              Text(
                '¡Bienvenido!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: tema.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Amasandería en marcha', //despues cambiar a turno
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),

              // boton para agendar pedido
              SizedBox(
                width: double.infinity, 
                height: 55,
                child: ElevatedButton.icon(
                    onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OrderFormScreen()),
                    );
                    },                  icon: const Icon(Icons.edit_document),
                  label: const Text(
                    'Agendar Pedido',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // boton para ver los pedidos
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                    onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrderListScreen()),
                    );
                    },                  icon: const Icon(Icons.calendar_today),
                  label: const Text(
                    'Ver Pedidos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}