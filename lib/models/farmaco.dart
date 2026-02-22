class Farmaco {
  final String nombreGenerico;
  final String? nombreComercial;
  final String? ph;
  final String? osmolaridad;
  final String? reconstituirDiluir;
  final String? protocoloHSO;
  final String? tiempoInfusion;
  final String? viaAdministracion;
  final Estabilidad estabilidad;

  Farmaco({
    required this.nombreGenerico,
    required this.nombreComercial,
    required this.ph,
    required this.osmolaridad,
    required this.reconstituirDiluir,
    required this.protocoloHSO,
    required this.tiempoInfusion,
    required this.viaAdministracion,
    required this.estabilidad,
  });

  factory Farmaco.fromJson(Map<String, dynamic> json) {
    return Farmaco(
      nombreGenerico: json['nombreGenerico'],
      nombreComercial: json['nombreComercial'],
      ph: json['ph'],
      osmolaridad: json['osmolaridad'],
      reconstituirDiluir: json['reconstituirDiluir'],
      protocoloHSO: json['protocoloHSO'],
      tiempoInfusion: json['tiempoInfusion'],
      viaAdministracion: json['viaAdministracion'],
      estabilidad: Estabilidad.fromJson(json['estabilidad']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombreGenerico': nombreGenerico,
      'nombreComercial': nombreComercial,
      'ph': ph,
      'osmolaridad': osmolaridad,
      'reconstituirDiluir': reconstituirDiluir,
      'protocoloHSO': protocoloHSO,
      'tiempoInfusion': tiempoInfusion,
      'viaAdministracion': viaAdministracion,
      'estabilidad': estabilidad.toJson(),
    };
  }
}

class Estabilidad {
  final bool usoInmediato;
  final String? estabilidad;
  final String? temperatura;
  final bool protegerDeLaLuz;
  final bool conservarEnvase;

  Estabilidad({
    required this.usoInmediato,
    required this.estabilidad,
    required this.temperatura,
    required this.protegerDeLaLuz,
    required this.conservarEnvase,
  });

  factory Estabilidad.fromJson(Map<String, dynamic> json) {
    return Estabilidad(
      usoInmediato: json['usoInmediato'],
      estabilidad: json['estabilidad'],
      temperatura: json['temperatura'],
      protegerDeLaLuz: json['protegerDeLaLuz'],
      conservarEnvase: json['conservarEnvase'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usoInmediato': usoInmediato,
      'estabilidad': estabilidad,
      'temperatura': temperatura,
      'protegerDeLaLuz': protegerDeLaLuz,
      'conservarEnvase': conservarEnvase,
    };
  }
}
