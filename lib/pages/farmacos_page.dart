import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/farmaco.dart';
import '../services/farmacos_service.dart';
import 'farmaco_detalle_page.dart';

class FarmacosPage extends StatefulWidget {
  const FarmacosPage({super.key});

  @override
  State<FarmacosPage> createState() => _FarmacosPageState();
}

class _FarmacosPageState extends State<FarmacosPage>
    with TickerProviderStateMixin {
  final FarmacosService _service = FarmacosService();

  List<Farmaco> _todos = [];
  List<Farmaco> _filtrados = [];
  String _busqueda = '';
  bool _ordenAZ = true;

  // Filtros
  bool _soloCVC = false;
  bool _soloUsoInmediato = false;
  bool _soloConEstabilidad = false;
  bool _osmBR = false; // <350
  bool _osmRM = false; // 350–500
  bool _osmAR = false; // >500

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final lista = await _service.cargarFarmacos();
    setState(() {
      _todos = List.from(lista);
      _aplicarFiltrosYBusqueda();
    });
  }

  void _aplicarFiltrosYBusqueda() {
    List<Farmaco> lista = List.from(_todos);

    // Búsqueda por texto
    final texto = _busqueda.toLowerCase();
    if (texto.isNotEmpty) {
      lista = lista.where((f) {
        final gen = f.nombreGenerico.toLowerCase();
        final com = (f.nombreComercial ?? '').toLowerCase();
        return gen.contains(texto) || com.contains(texto);
      }).toList();
    }

    // Filtro solo CVC
    if (_soloCVC) {
      lista = lista.where((f) {
        final via = (f.viaAdministracion ?? '').toLowerCase();
        return via.contains('cvc');
      }).toList();
    }

    // Filtro uso inmediato
    if (_soloUsoInmediato) {
      lista = lista.where((f) => f.estabilidad?.usoInmediato == true).toList();
    }

    // Filtro con estabilidad (campo no nulo)
    if (_soloConEstabilidad) {
      lista = lista
          .where((f) =>
              f.estabilidad != null &&
              (f.estabilidad!.estabilidad ?? '').trim().isNotEmpty)
          .toList();
    }

    // Filtros por osmolaridad
    if (_osmBR || _osmRM || _osmAR) {
      lista = lista.where((f) {
        final riesgo = _clasificarOsmolaridad(f.osmolaridad);
        if (riesgo == _RiesgoOsm.br && _osmBR) return true;
        if (riesgo == _RiesgoOsm.rm && _osmRM) return true;
        if (riesgo == _RiesgoOsm.ar && _osmAR) return true;
        return false;
      }).toList();
    }

    // Orden
    lista.sort((a, b) => _ordenAZ
        ? a.nombreGenerico.compareTo(b.nombreGenerico)
        : b.nombreGenerico.compareTo(a.nombreGenerico));

    setState(() {
      _filtrados = lista;
    });
  }

  void _filtrarTexto(String texto) {
    _busqueda = texto;
    _aplicarFiltrosYBusqueda();
  }

  void _cambiarOrden() {
    _ordenAZ = !_ordenAZ;
    _aplicarFiltrosYBusqueda();
  }

  // Colores según osmolaridad
  _RiesgoOsm _clasificarOsmolaridad(String? osm) {
    if (osm == null) return _RiesgoOsm.desconocido;
    final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(osm.replaceAll(',', '.'));
    if (match == null) return _RiesgoOsm.desconocido;
    final valor = double.tryParse(match.group(1) ?? '');
    if (valor == null) return _RiesgoOsm.desconocido;
    if (valor < 350) return _RiesgoOsm.br;
    if (valor <= 500) return _RiesgoOsm.rm;
    return _RiesgoOsm.ar;
  }

  Color _colorPorOsmolaridad(String? osm) {
    final riesgo = _clasificarOsmolaridad(osm);
    switch (riesgo) {
      case _RiesgoOsm.br:
        return const Color(0xFFC8E6C9); // verde claro
      case _RiesgoOsm.rm:
        return const Color(0xFFFFF9C4); // amarillo claro
      case _RiesgoOsm.ar:
        return const Color(0xFFFFCDD2); // rojo claro
      case _RiesgoOsm.desconocido:
      default:
        return Colors.white;
    }
  }

  // Bottom sheet genérico (adaptativo)
  void _mostrarBottomSheetWidget(String titulo, Widget contenido) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.2,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: contenido,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Bottom sheet de filtros
  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        bool soloCVC = _soloCVC;
        bool soloUsoInmediato = _soloUsoInmediato;
        bool soloConEstabilidad = _soloConEstabilidad;
        bool osmBR = _osmBR;
        bool osmRM = _osmRM;
        bool osmAR = _osmAR;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Filtros avanzados",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Vía de administración",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          CheckboxListTile(
                            title: const Text("Solo CVC"),
                            value: soloCVC,
                            onChanged: (v) {
                              setModalState(() => soloCVC = v ?? false);
                            },
                          ),
                          const SizedBox(height: 8),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Uso inmediato / estabilidad",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          CheckboxListTile(
                            title: const Text("Solo fármacos de uso inmediato"),
                            value: soloUsoInmediato,
                            onChanged: (v) {
                              setModalState(
                                  () => soloUsoInmediato = v ?? false);
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Solo con estabilidad definida"),
                            value: soloConEstabilidad,
                            onChanged: (v) {
                              setModalState(
                                  () => soloConEstabilidad = v ?? false);
                            },
                          ),
                          const SizedBox(height: 8),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Osmolaridad (riesgo de flebitis)",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          CheckboxListTile(
                            title: const Text("Bajo riesgo (< 350 mOsm/l)"),
                            value: osmBR,
                            onChanged: (v) {
                              setModalState(() => osmBR = v ?? false);
                            },
                          ),
                          CheckboxListTile(
                            title:
                                const Text("Riesgo moderado (350–500 mOsm/l)"),
                            value: osmRM,
                            onChanged: (v) {
                              setModalState(() => osmRM = v ?? false);
                            },
                          ),
                          CheckboxListTile(
                            title: const Text("Alto riesgo (> 500 mOsm/l)"),
                            value: osmAR,
                            onChanged: (v) {
                              setModalState(() => osmAR = v ?? false);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text("Limpiar"),
                        onPressed: () {
                          setState(() {
                            _soloCVC = false;
                            _soloUsoInmediato = false;
                            _soloConEstabilidad = false;
                            _osmBR = false;
                            _osmRM = false;
                            _osmAR = false;
                            _aplicarFiltrosYBusqueda();
                          });
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        child: const Text("Aplicar"),
                        onPressed: () {
                          setState(() {
                            _soloCVC = soloCVC;
                            _soloUsoInmediato = soloUsoInmediato;
                            _soloConEstabilidad = soloConEstabilidad;
                            _osmBR = osmBR;
                            _osmRM = osmRM;
                            _osmAR = osmAR;
                            _aplicarFiltrosYBusqueda();
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Abrir PDF desde assets (solución multiplataforma sin paquetes externos)
  Future<void> _abrirPDF() async {
    try {
      final byteData = await rootBundle
          .load('assets/archivo_pdf/tabla_farmacos_rea_huso.pdf');
      final bytes = byteData.buffer.asUint8List();

      final tempDir = Directory.systemTemp;
      final filePath =
          '${tempDir.path}${Platform.pathSeparator}tabla_farmacos_rea_huso.pdf';
      final file = File(filePath);

      await file.writeAsBytes(bytes, flush: true);

      if (Platform.isWindows) {
        await Process.start('explorer', [file.path]);
      } else if (Platform.isMacOS) {
        await Process.start('open', [file.path]);
      } else if (Platform.isLinux) {
        await Process.start('xdg-open', [file.path]);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plataforma no soportada para abrir archivos.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el PDF: $e')),
        );
      }
    }
  }

  // Navegación con animación slide + fade
  void _abrirDetalle(Farmaco f) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) =>
            FarmacoDetallePage(farmaco: f),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final offsetAnim =
              Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));
          final fadeAnim = CurvedAnimation(
            parent: animation,
            curve: Curves.easeIn,
          );
          return SlideTransition(
            position: offsetAnim,
            child: FadeTransition(
              opacity: fadeAnim,
              child: child,
            ),
          );
        },
      ),
    );
  }

  // Widget auxiliar para la leyenda de colores (usado en Abreviaturas)
  Widget _leyendaColores() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text(
          "Leyenda de colores (osmolaridad / riesgo de flebitis):",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _colorBoxLabel(const Color(0xFFC8E6C9), "Bajo riesgo (BR) < 350 mOsm/l"),
            const SizedBox(width: 12),
            _colorBoxLabel(const Color(0xFFFFF9C4), "Riesgo moderado (RM) 350–500 mOsm/l"),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _colorBoxLabel(const Color(0xFFFFCDD2), "Alto riesgo (AR) > 500 mOsm/l"),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Nota: osmolaridad alta y pH extremos aumentan el riesgo de flebitis; usar CVC si procede.",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _colorBoxLabel(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black12),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fármacos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
          ),
          IconButton(
            icon: Icon(_ordenAZ ? Icons.sort_by_alpha : Icons.sort),
            onPressed: _cambiarOrden,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _abrirPDF,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (i) {
          if (i == 0) {
            _mostrarBottomSheetWidget(
              "Bibliografía",
              const Text(
                "1-Bibliografía: (1) Agencia Española de Medicamentos y Productos Sanitarios (CIMA). Centro de Información de Medicamentos; (2) Manrique-Rodríguez S, Heras-Hidalgo I, Pernia-López MS, Herranz-Alonso A, del Río Pisabarro MC, Suárez-Mier MB, et al. Standardization and Chemical Characterization of Intravenous Therapy in Adult Patients: A Step Further in Medication Safety. Drugs R D. 2021; (3) Sociedad Española de Farmacia Hospitalaria. Estabilidad y compatibilidad de medicamentos. Laboratorios Grifols. 2025. (4) Paw HGW, Shulman R. Handbook of drugs in intensive care: An A-Z guide. Handbook of Drugs in Intensive Care: An A-Z Guide. 2019.",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),
            );
          } else if (i == 1) {
            _mostrarBottomSheetWidget(
              "Autores",
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    "Autoría: Siles F; Montalbán D; Jaime G; Mejía R A; Ramos R; Gómez N; Cano S; de la Flor M; Servicio de Anestesia y Reanimación del Hospital Universitario Severo Ochoa. Mayo 2025.\n",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, height: 1.4),
                  ),
                  Divider(),
                  SizedBox(height: 6),
                  Text(
                    "Digitalizado por Pedro Omar Sevilla Moreno - ENFERMERO - Febrero de 2025, con ayuda de Copilot.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          } else if (i == 2) {
            // Abreviaturas + leyenda de colores
            _mostrarBottomSheetWidget(
              "Abreviaturas y Colores",
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "FT= Ficha Técnica; pH↓= pH ácido (no se ha encontrado valor); SSF 0,9%= Solución estéril de Cloruro de Sodio al 0,9%; Dx 5%= Solución de Glucosa al 5%. ; API= Agua Para Inyección; g= gramos; mg= miligramos; μg= microgramos; ml= mililitros; UI= Unidades Internacionales; h= hora; s/ p= si precisa; IV= Intravenosa; D. C= Dosis de Carga; PC: Perfusión Continua; PC- BI= Perfusión Continua con Bomba de Infusión; PCA: Perfusión de Analgesia Controlada; NYOSH: Instituto Nacional para la Salud y Seguridad Ocupacional (EE. UU); HDA= Hemorragia Digestiva Alta; TEC= Terapia Electro- Convulsiva. CVC= Cáteter venoso central. CVP= Cáteter venoso periférico. Min./min.=Minutos.",
                    style: TextStyle(fontSize: 15, height: 1.4),
                  ),
                  _leyendaColores(),
                ],
              ),
            );
          } else if (i == 3) {
            _mostrarBottomSheetWidget(
              "Notas de los autores",
              const Text(
                "4-Columna Vía IV de Administración/ Irritante/ Vesicante: sólo se han anotado aquellos fármacos que deban pasar exclusivamente por CVC. Aquellos medicamentos en que no está especificado, se pueden utilizar indistintamente el CVP o el CVC. Según el protocolo español Flebitis 0 existe riesgo de flebitis química del endotelio venoso por soluciones ácidas, alcalinas e hipertónicas. Cuanto más ácida (especialmente inferior a 4.1) o alcalina (especialmente superior a 9.0) sea una solución, más irritante será. (Kokotis, 1998). La osmolaridad también influirá en la irritación de la vena. Alto riesgo (AR)>500 mOsm/l. Riesgo moderado (RM) entre 350 y 500 mOsm/l y bajo riesgo (BR)<350 mOsm/l. NPT: no administrar por VVP si>600 mOsm/l (Carballo et al.2004).\n\n5-Estabilidad Físico/Química de las soluciones y Fotosensibilidad: a) Una vez abierto el vial del fármaco, usar inmediatamente. Desde el punto de vista microbiológico, la solución para perfusión debe ser empleada inmediatamente. Algunos medicamentos no contienen ningún conservante. b) Estabilidad físico-química del fármaco o de la disolución, una vez reconstituido o añadido a la misma. c) Temperatura de conservación. Conservar frio, entre 2-8º C. Nunca congelar. d) Una vez reconstituida la solución debe protegerse de la luz. e) Mantener el vial en su envase exterior para protegerlo de la luz.\n\n6-Protocolo de Seguridad en Reanimación y Anestesia, en el manejo de Fármacos Hipnóticos, Opioides y Relajantes Musculares, deberán ir cargados de la siguiente manera: Hipnóticos en jeringa de 20 ml; Opioides en jeringa de 10 ml; y Relajantes musculares en jeringa de 5 ml (en ocasiones, éstos últimos ya vienen precargados).",
                style: TextStyle(fontSize: 15, height: 1.4),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book), label: "Bibliografía"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Autores"),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: "Abreviaturas"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "Notas"),
        ],
      ),
      body: _todos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ENCABEZADO
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: Colors.grey.shade200,
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/logos/hospital_severo_ochoa.jpg',
                        height: 40,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Servicio de Anestesia y Reanimación",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                // AUTOCOMPLETE con botón de borrar (círculo con X)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Autocomplete<Farmaco>(
                    optionsBuilder: (text) {
                      if (text.text.isEmpty) return const Iterable<Farmaco>.empty();
                      final query = text.text.toLowerCase();
                      return _todos.where((f) =>
                          f.nombreGenerico.toLowerCase().contains(query) ||
                          (f.nombreComercial ?? '')
                              .toLowerCase()
                              .contains(query));
                    },
                    displayStringForOption: (f) =>
                        "${f.nombreGenerico}${f.nombreComercial != null ? ' (${f.nombreComercial})' : ''}",
                    onSelected: (f) => _abrirDetalle(f),
                    fieldViewBuilder:
                        (_, TextEditingController controller, focus, onSubmit) {
                      // Usamos ValueListenableBuilder para actualizar el suffixIcon
                      return ValueListenableBuilder<TextEditingValue>(
                        valueListenable: controller,
                        builder: (context, value, child) {
                          return TextField(
                            controller: controller,
                            focusNode: focus,
                            decoration: InputDecoration(
                              labelText: 'Buscar fármaco...',
                              prefixIcon: const Icon(Icons.search),
                              border: const OutlineInputBorder(),
                              // Suffix: botón claro (círculo con X) que borra el texto y aplica filtro vacío
                              suffixIcon: value.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        controller.clear();
                                        _filtrarTexto('');
                                        // devolver foco al campo
                                        FocusScope.of(context).requestFocus(focus);
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (text) {
                              _filtrarTexto(text);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                // LISTA CON TARJETAS
                Expanded(
                  child: ListView.builder(
                    itemCount: _filtrados.length,
                    itemBuilder: (context, i) {
                      final f = _filtrados[i];
                      final colorFondo = _colorPorOsmolaridad(f.osmolaridad);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorFondo,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          title: Text(
                            f.nombreGenerico,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (f.nombreComercial != null)
                                Text(
                                  f.nombreComercial!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              if (f.osmolaridad != null)
                                Text(
                                  "Osmolaridad: ${f.osmolaridad}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              if (f.viaAdministracion != null)
                                Text(
                                  "Vía: ${f.viaAdministracion}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _abrirDetalle(f),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

enum _RiesgoOsm { br, rm, ar, desconocido }
