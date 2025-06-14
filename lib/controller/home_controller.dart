// ignore_for_file: deprecated_member_use

import 'package:finpay/api/local.db.service.dart';
import 'package:finpay/config/images.dart';
import 'package:finpay/config/textstyle.dart';
import 'package:finpay/model/sitema_reservas.dart';
import 'package:finpay/model/pago.dart';
import 'package:finpay/model/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  List<TransactionModel> transactionList = List<TransactionModel>.empty().obs;
  RxBool isWeek = true.obs;
  RxBool isMonth = false.obs;
  RxBool isYear = false.obs;
  RxBool isAdd = false.obs;

  RxList<Pago> pagosConfirmados = <Pago>[].obs;
  RxList<Pago> pagosPendientes = <Pago>[].obs;
  RxList<Auto> autosCliente = <Auto>[].obs;

  @override
  void onInit() {
    super.onInit();
    customInit();
  }

  Future<void> customInit() async {
    await cargarPagos();
    await cargarAutosCliente();
    _cargarTransaccionesMock();
  }

  void _cargarTransaccionesMock() {
    transactionList = [
      TransactionModel(
        Theme.of(Get.context!).textTheme.titleLarge!.color,
        DefaultImages.transaction4,
        "Apple Store",
        "iPhone 12 Case",
        "- \$120,90",
        "09:39 AM",
      ),
      TransactionModel(
        HexColor(AppTheme.primaryColorString!).withOpacity(0.10),
        DefaultImages.transaction3,
        "Ilya Vasil",
        "Wise • 5318",
        "- \$50,90",
        "05:39 AM",
      ),
      TransactionModel(
        Theme.of(Get.context!).textTheme.titleLarge!.color,
        "",
        "Burger King",
        "Cheeseburger XL",
        "- \$5,90",
        "09:39 AM",
      ),
      TransactionModel(
        HexColor(AppTheme.primaryColorString!).withOpacity(0.10),
        DefaultImages.transaction1,
        "Claudia Sarah",
        "Finpay Card • 5318",
        "- \$50,90",
        "04:39 AM",
      ),
    ];
  }

  Future<void> cargarPagos() async {
    final db = LocalDBService();
    final data = await db.getAll("pagos.json");

    final pagos = data.map((json) => Pago.fromJson(json)).toList();

    pagosConfirmados.value =
        pagos.where((p) => p.estado.toUpperCase() == 'CONFIRMADO').toList();

    pagosPendientes.value =
        pagos.where((p) => p.estado.toUpperCase() == 'PENDIENTE').toList();
  }

  Future<void> cargarAutosCliente() async {
    final db = LocalDBService();
    final data = await db.getAll("autos.json");

    autosCliente.value = data
        .map((e) => Auto.fromJson(e))
        .where((a) => a.clienteId == "cliente_1")
        .toList();
  }

  /// ⚠️ Llamar a esto cada vez que regresás del flujo de reservas
  Future<void> recargarDatos() async {
    await cargarPagos();
    await cargarAutosCliente();
  }
}
