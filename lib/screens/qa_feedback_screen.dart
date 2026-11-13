import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

class QaFeedbackScreen extends StatefulWidget {
  const QaFeedbackScreen({super.key});

  @override
  State<QaFeedbackScreen> createState() => _QaFeedbackScreenState();
}

class _QaFeedbackScreenState extends State<QaFeedbackScreen> {
  Map<String, dynamic>? encuestaData;
  final Map<String, int> respuestas = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarEncuesta();
  }

  Future<void> _cargarEncuesta() async {
    try {
      final String jsonString = await rootBundle.loadString('lib/assets/encuesta_qa.json');
      setState(() {
        encuestaData = jsonDecode(jsonString);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _enviarFeedback() {
    if (encuestaData == null) return;
    
    String reporte = "Resultados Beta Testing - Amasandería\n\n";
    respuestas.forEach((id, puntaje) {
      reporte += "Pregunta $id: $puntaje estrellas\n";
    });

    Share.share(reporte, subject: 'Resultados QA Amasandería');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (encuestaData == null) {
      return const Scaffold(body: Center(child: Text("Error cargando JSON")));
    }

    final cumplimiento = encuestaData!['cumplimiento_hu'] as List;
    final usabilidad = encuestaData!['usabilidad'] as List;
    final todasLasPreguntas = [...cumplimiento, ...usabilidad];

    final theme = Theme.of(context);
    final moradoPrincipal = theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Validación QA', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: todasLasPreguntas.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final pregunta = todasLasPreguntas[index];
                final id = pregunta['id'];
                final puntajeActual = respuestas[id] ?? pregunta['valor'] as int;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pregunta['titulo'], 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(5, (starIndex) {
                            final int valorEstrella = starIndex + 1;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  respuestas[id] = valorEstrella;
                                });
                              },
                              child: Icon(
                                valorEstrella <= puntajeActual ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 40,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                pregunta['min'], 
                                style: const TextStyle(fontSize: 12, color: Colors.grey)
                              ),
                            ),
                            Expanded(
                              child: Text(
                                pregunta['max'], 
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _enviarFeedback,
                  icon: const Icon(Icons.share),
                  label: const Text(
                    'Compartir Feedback',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: moradoPrincipal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}