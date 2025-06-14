// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:finpay/model/pago.dart';
import 'package:finpay/config/images.dart';
import 'package:finpay/config/textstyle.dart';

class Pago {
  final String codigoPago;
  final String codigoReservaAsociada;
  final double montoPagado;
  final DateTime fechaPago;
  final String estado;
  final String? codigoLugar;

  Pago({
    required this.codigoPago,
    required this.codigoReservaAsociada,
    required this.montoPagado,
    required this.fechaPago,
    required this.estado,
    this.codigoLugar,
  });

  factory Pago.fromJson(Map<String, dynamic> json) {
    return Pago(
      codigoPago: json['codigoPago'],
      codigoReservaAsociada: json['codigoReservaAsociada'],
      montoPagado: (json['montoPagado'] as num).toDouble(),
      fechaPago: DateTime.parse(json['fechaPago']),
      estado: json['estado'],
      codigoLugar: json['codigoLugar'],
    );
  }
}

class LocalDBService {
  Future<String> _getFilePath(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$filename';
  }

  Future<File> _getFile(String filename, {bool forceUpdate = false}) async {
    final path = await _getFilePath(filename);
    final file = File(path);

    if (forceUpdate || !await file.exists()) {
      final data = await rootBundle.loadString('assets/data/$filename');
      await file.writeAsString(data);
    }

    return file;
  }

  Future<List<Map<String, dynamic>>> getAll(String filename,
      {bool forceUpdate = false}) async {
    final file = await _getFile(filename, forceUpdate: forceUpdate);
    final contents = await file.readAsString();
    return List<Map<String, dynamic>>.from(jsonDecode(contents));
  }

  Future<void> saveAll(String filename, List<Map<String, dynamic>> data) async {
    final file = await _getFile(filename);
    await file.writeAsString(jsonEncode(data));
  }
}

class TopUpSCreen extends StatefulWidget {
  const TopUpSCreen({Key? key}) : super(key: key);

  @override
  State<TopUpSCreen> createState() => _TopUpSCreenState();
}

class _TopUpSCreenState extends State<TopUpSCreen> {
  final LocalDBService _dbService = LocalDBService();
  List<Pago> pagosPendientes = [];
  List<String> pagosSeleccionados = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _loadPagosPendientes();
  }

  Future<void> _loadPagosPendientes() async {
    final rawList = await _dbService.getAll('pagos.json');
    final pagos = rawList.map((e) => Pago.fromJson(e)).toList();
    final pendientes =
    pagos.where((p) => p.estado.toUpperCase() == 'PENDIENTE').toList();
    setState(() {
      pagosPendientes = pendientes;
      pagosSeleccionados.clear();
      cargando = false;
    });
  }

  Future<void> _confirmarPagosSeleccionados() async {
    final rawList = await _dbService.getAll('pagos.json');
    final lugares = await _dbService.getAll('lugares.json');

    final pagosActualizados = rawList.map((pagoMap) {
      if (pagosSeleccionados.contains(pagoMap['codigoPago'])) {
        final codigoLugar = pagoMap['codigoLugar'];
        if (codigoLugar != null) {
          final index = lugares.indexWhere((l) => l['codigoLugar'] == codigoLugar);
          if (index != -1) {
            lugares[index]['estado'] = 'DISPONIBLE';
          }
        }

        return {
          ...pagoMap,
          'estado': 'CONFIRMADO',
        };
      }
      return pagoMap;
    }).toList();

    await _dbService.saveAll('pagos.json', pagosActualizados);
    await _dbService.saveAll('lugares.json', lugares);

    Get.snackbar("Éxito", "Pagos confirmados y lugares liberados",
        backgroundColor: Colors.green, colorText: Colors.white);

    await _loadPagosPendientes();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.isLightTheme == false
          ? HexColor('#15141f')
          : HexColor(AppTheme.primaryColorString!),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
            children: [
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      "Top Up",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    const Icon(Icons.arrow_back, color: Colors.transparent),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  width: Get.width,
                  decoration: BoxDecoration(
                    color: AppTheme.isLightTheme == false
                        ? const Color(0xff211F32)
                        : Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: cargando
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xffF5F7FE),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child:
                                SvgPicture.asset(DefaultImages.unicorn),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Finpay Card",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "••••   ••••   ••••   5318",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xffA2A0A8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Pagos pendientes",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      pagosPendientes.isEmpty
                          ? const Text(
                        "No hay pagos pendientes.",
                        style: TextStyle(fontSize: 16),
                      )
                          : Column(
                        children: pagosPendientes.map((pago) {
                          final seleccionado = pagosSeleccionados
                              .contains(pago.codigoPago);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (seleccionado) {
                                  pagosSeleccionados
                                      .remove(pago.codigoPago);
                                } else {
                                  pagosSeleccionados
                                      .add(pago.codigoPago);
                                }
                              });
                            },
                            child: Card(
                              color: seleccionado
                                  ? HexColor(AppTheme
                                  .primaryColorString!)
                                  .withOpacity(0.1)
                                  : null,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: seleccionado
                                      ? HexColor(AppTheme
                                      .primaryColorString!)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons
                                    .pending_actions_outlined),
                                title: Text(
                                    "Reserva: ${pago.codigoReservaAsociada}"),
                                subtitle: Text(
                                    "Fecha: ${pago.fechaPago.day}-${pago.fechaPago.month}-${pago.fechaPago.year}"),
                                trailing: Text(
                                  "Gs. ${pago.montoPagado.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 20),
            child: GestureDetector(
              onHorizontalDragEnd: (_) {
                if (pagosSeleccionados.isNotEmpty) {
                  _confirmarPagosSeleccionados();
                } else {
                  Get.snackbar("Aviso", "Selecciona al menos un pago",
                      backgroundColor: Colors.orange,
                      colorText: Colors.white);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 56,
                width: Get.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.isLightTheme == false
                      ? HexColor(AppTheme.primaryColorString!)
                      : HexColor(AppTheme.primaryColorString!)
                      .withOpacity(0.05),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppTheme.isLightTheme == false
                              ? Colors.white
                              : HexColor(AppTheme.primaryColorString!),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgPicture.asset(
                            DefaultImages.swipe,
                            color: AppTheme.isLightTheme == false
                                ? HexColor(AppTheme.primaryColorString!)
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      "Swipe para confirmar",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
