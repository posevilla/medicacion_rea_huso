import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/farmaco.dart';

class FarmacosService {
  Future<List<Farmaco>> cargarFarmacos() async {
    // 1. Leer el archivo JSON desde assets
    final String data = await rootBundle.loadString('assets/data/farmacos.json');

    // 2. Decodificar el JSON a una lista dinámica
    final List<dynamic> lista = json.decode(data);

    // 3. Convertir cada elemento en un objeto Farmaco
    final List<Farmaco> farmacos =
        lista.map((item) => Farmaco.fromJson(item)).toList();

    return farmacos;
  }
}
