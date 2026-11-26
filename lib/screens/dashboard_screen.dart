import 'package:flutter/material.dart';
import 'package:gestion_amasanderia/screens/order_from_screen.dart';
import 'package:gestion_amasanderia/screens/order_list_screen.dart';
import 'package:gestion_amasanderia/screens/qa_feedback_screen.dart';
import 'package:gestion_amasanderia/viewmodel/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nombreEmpleado = context.watch<AuthViewModel>().nombreEmpleado;
    final theme = Theme.of(context);
    final moradoPrincipal =
        theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Gestión de Pedidos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            // Cabecera morada de borde a borde
            Container(
              width: double.infinity,
              color: moradoPrincipal,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'lib/assets/icons/logo.png',
                            height: 68,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Amasandería La Lela',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(
                        color: Colors.white70,
                        thickness: 1,
                        height: 1,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        nombreEmpleado,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(
                Icons.receipt_long_outlined,
                color: moradoPrincipal,
              ),
              title: const Text(
                'Gestión de Pedidos',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.fact_check_outlined,
                color: moradoPrincipal,
              ),
              title: const Text(
                'Evaluar App (QA)',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QaFeedbackScreen(),
                  ),
                );
              },
            ),
            const Spacer(),
            // Botón de cerrar sesión anclado al fondo
            Container(
              width: double.infinity,
              color: moradoPrincipal,
              child: SafeArea(
                top: false,
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text(
                    'Cerrar sesión',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await context.read<AuthViewModel>().logout();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/icons/logo.png',
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Text(
                '¡Bienvenido, $nombreEmpleado!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: moradoPrincipal,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderFormScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_document),
                  label: const Text(
                    'Agendar Pedido',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderListScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text(
                    'Ver Pedidos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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