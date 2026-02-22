import 'package:flutter/material.dart';
import '../models/farmaco.dart';

class FarmacoDetallePage extends StatelessWidget {
  final Farmaco farmaco;

  const FarmacoDetallePage({super.key, required this.farmaco});

  Widget _item(String titulo, String? valor) {
    if (valor == null || valor.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _itemBool(String titulo, bool valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Icon(
            valor ? Icons.check_circle : Icons.cancel,
            color: valor ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = farmaco.estabilidad;

    return Scaffold(
      appBar: AppBar(
        title: Text(farmaco.nombreGenerico),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Tarjeta principal con datos del fármaco
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre genérico
                    Text(
                      farmaco.nombreGenerico,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Nombre comercial
                    if (farmaco.nombreComercial != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        farmaco.nombreComercial!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    _item("pH", farmaco.ph),
                    _item("Osmolaridad", farmaco.osmolaridad),
                    _item("Reconstituir / Diluir", farmaco.reconstituirDiluir),
                    _item("Protocolo HSO", farmaco.protocoloHSO),
                    _item("Tiempo de infusión", farmaco.tiempoInfusion),
                    _item("Vía de administración", farmaco.viaAdministracion),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Tarjeta de estabilidad
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Estabilidad",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _itemBool("Uso inmediato", e.usoInmediato),
                    _item("Estabilidad", e.estabilidad),
                    _item("Temperatura", e.temperatura),
                    _itemBool("Proteger de la luz", e.protegerDeLaLuz),
                    _itemBool("Conservar en envase original", e.conservarEnvase),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
