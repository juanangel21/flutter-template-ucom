// home_view.dart

import 'package:finpay/config/images.dart';
import 'package:finpay/config/textstyle.dart';
import 'package:finpay/controller/home_controller.dart';
import 'package:finpay/controller/reserva_controller.dart';
import 'package:finpay/model/sitema_reservas.dart';
import 'package:finpay/utils/utiles.dart';
import 'package:finpay/view/home/top_up_screen.dart';
import 'package:finpay/view/home/widget/circle_card.dart';
import 'package:finpay/view/reservas/reservas_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  final HomeController homeController;

  const HomeView({Key? key, required this.homeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.isLightTheme == false ? const Color(0xff15141F) : Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Good morning",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).textTheme.bodySmall!.color,
                      ),
                    ),
                    Text(
                      "Good morning",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      height: 28,
                      width: 69,
                      decoration: BoxDecoration(
                        color: const Color(0xffF6A609).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(DefaultImages.ranking),
                          Text(
                            "Gold",
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: const Color(0xffF6A609),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: Image.asset(DefaultImages.avatar),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 20),

                // Botones "Pagar" y "Reservar"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.to(const TopUpSCreen(),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 500));
                      },
                      child: circleCard(
                        image: DefaultImages.topup,
                        title: "Pagar",
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(() => ReservaScreen(),
                          binding: BindingsBuilder(() {
                            Get.delete<ReservaController>();
                            Get.create(() => ReservaController());
                          }),
                          transition: Transition.downToUp,
                          duration: const Duration(milliseconds: 500),
                        );
                      },
                      child: circleCard(
                        image: DefaultImages.transfer,
                        title: "Reservar",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Cantidad de pagos confirmados
                Obx(() {
                  final cantidadConfirmados = homeController.pagosConfirmados.length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Pagos realizados: $cantidadConfirmados",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // Pagos pendientes
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Pagos pendientes",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      Obx(() {
                        final pendientes = homeController.pagosPendientes;
                        if (pendientes.isEmpty) {
                          return const Text("No hay pagos pendientes.");
                        }
                        return Column(
                          children: pendientes.map((pago) {
                            return ListTile(
                              leading: const Icon(Icons.warning),
                              title: Text("Reserva: ${pago.codigoReservaAsociada}"),
                              subtitle: Text("Fecha: ${UtilesApp.formatearFechaDdMMAaaa(pago.fechaPago)}"),
                              trailing: Text(
                                UtilesApp.formatearGuaranies(pago.montoPagado),
                                style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Mis vehículos
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Mis vehículos",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      Obx(() {
                        final autos = homeController.autosCliente;
                        if (autos.isEmpty) {
                          return const Text("No hay vehículos registrados.");
                        }
                        return Column(
                          children: autos.map((Auto auto) {
                            return ListTile(
                              leading: const Icon(Icons.directions_car),
                              title: Text("${auto.marca} ${auto.modelo}"),
                              subtitle: Text("Chapa: ${auto.chapa}"),
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Pagos previos (confirmados)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.isLightTheme == false
                          ? const Color(0xff211F32)
                          : const Color(0xffFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff000000).withOpacity(0.10),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Pagos previos",
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(() {
                          final previos = homeController.pagosConfirmados;
                          if (previos.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text("No hay pagos confirmados aún."),
                            );
                          }
                          return Column(
                            children: previos.map((pago) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: const Icon(Icons.payments_outlined),
                                  title: Text("Reserva: ${pago.codigoReservaAsociada}"),
                                  subtitle: Text("Fecha: ${UtilesApp.formatearFechaDdMMAaaa(pago.fechaPago)}"),
                                  trailing: Text(
                                    UtilesApp.formatearGuaranies(pago.montoPagado),
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
