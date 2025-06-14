import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/reserva_controller.dart';
import 'package:finpay/model/sitema_reservas.dart';
import 'package:finpay/utils/utiles.dart';

class ReservaScreen extends StatelessWidget {
  final controller = Get.put(ReservaController());

  ReservaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reservar lugar")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Seleccionar auto", style: TextStyle(fontWeight: FontWeight.bold)),
                Obx(() {
                  return DropdownButton<Auto>(
                    isExpanded: true,
                    value: controller.autoSeleccionado.value,
                    hint: const Text("Seleccionar auto"),
                    onChanged: (auto) => controller.autoSeleccionado.value = auto,
                    items: controller.autosCliente.map((a) {
                      final nombre = "${a.chapa} - ${a.marca} ${a.modelo}";
                      return DropdownMenuItem(value: a, child: Text(nombre));
                    }).toList(),
                  );
                }),
                const SizedBox(height: 16),
                const Text("Seleccionar piso", style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<Piso>(
                  isExpanded: true,
                  value: controller.pisoSeleccionado.value,
                  hint: const Text("Seleccionar piso"),
                  onChanged: (p) => controller.seleccionarPiso(p!),
                  items: controller.pisos.map((p) => DropdownMenuItem(value: p, child: Text(p.descripcion))).toList(),
                ),
                const SizedBox(height: 16),
                const Text("Seleccionar lugar", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: GridView.count(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: controller.lugaresDisponibles
                        .where((l) => l.codigoPiso == controller.pisoSeleccionado.value?.codigo)
                        .map((lugar) {
                      final seleccionado = lugar == controller.lugarSeleccionado.value;
                      final color = lugar.estado == "RESERVADO"
                          ? Colors.red
                          : seleccionado
                          ? Colors.green
                          : Colors.grey.shade300;

                      return GestureDetector(
                        onTap: lugar.estado == "DISPONIBLE"
                            ? () => controller.lugarSeleccionado.value = lugar
                            : null,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(color: seleccionado ? Colors.green.shade700 : Colors.black12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.directions_car, size: 28, color: lugar.estado == "RESERVADO" ? Colors.white : seleccionado ? Colors.white : Colors.black87),
                              const SizedBox(height: 4),
                              Text(lugar.codigoLugar, style: const TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Seleccionar fecha de ingreso", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final fecha = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (fecha == null) return;

                    final inicio = DateTime(fecha.year, fecha.month, fecha.day, 8, 0);
                    controller.horarioInicio.value = inicio;

                    final duracion = controller.duracionSeleccionada.value;
                    if (duracion != null) {
                      controller.horarioSalida.value = inicio.add(Duration(hours: duracion));
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Obx(() => Text(
                    controller.horarioInicio.value == null
                        ? "Seleccionar fecha"
                        : UtilesApp.formatearFechaDdMMAaaa(controller.horarioInicio.value!),
                  )),
                ),
                const SizedBox(height: 16),
                const Text("Duración de la reserva", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [1, 2, 4, 6, 8].map((horas) {
                    final seleccionada = controller.duracionSeleccionada.value == horas;
                    return ChoiceChip(
                      label: Text("$horas h"),
                      selected: seleccionada,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      onSelected: (_) {
                        controller.duracionSeleccionada.value = horas;
                        final inicio = controller.horarioInicio.value;
                        if (inicio != null) {
                          controller.horarioSalida.value = inicio.add(Duration(hours: horas));
                        }
                      },
                    );
                  }).toList(),
                ),
                Obx(() {
                  final inicio = controller.horarioInicio.value;
                  final salida = controller.horarioSalida.value;

                  if (inicio == null || salida == null) return const SizedBox();

                  final minutos = salida.difference(inicio).inMinutes;
                  final horas = minutos / 60;
                  final monto = (horas * 10000).round();

                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Desde: ${UtilesApp.formatearFechaDdMMAaaa(inicio)} ${TimeOfDay.fromDateTime(inicio).format(context)}"),
                        Text("Hasta: ${UtilesApp.formatearFechaDdMMAaaa(salida)} ${TimeOfDay.fromDateTime(salida).format(context)}"),
                        const SizedBox(height: 4),
                        Text("Monto estimado: ${UtilesApp.formatearGuaranies(monto)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final inicio = controller.horarioInicio.value;
                      final salida = controller.horarioSalida.value;

                      if (inicio != null && salida != null && salida.isBefore(inicio)) {
                        Get.snackbar("Error", "La hora de salida no puede ser anterior a la hora de entrada",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.red.shade900,
                        );
                        return;
                      }

                      final confirmacion = await _mostrarPopupConfirmacion(context);
                      if (!confirmacion) return;

                      final confirmada = await controller.confirmarReserva();

                      if (confirmada) {
                        Get.snackbar("Reserva", "Reserva realizada con éxito", snackPosition: SnackPosition.BOTTOM);
                        await Future.delayed(const Duration(milliseconds: 2000));
                        Get.back();
                      } else {
                        Get.snackbar("Error", "Verificá que todos los campos estén completos",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.red.shade900,
                        );
                      }
                    },
                    child: const Text("Confirmar reserva", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Future<bool> _mostrarPopupConfirmacion(BuildContext context) async {
    final piso = controller.pisoSeleccionado.value;
    final lugar = controller.lugarSeleccionado.value;
    final auto = controller.autoSeleccionado.value;
    final inicio = controller.horarioInicio.value;
    final salida = controller.horarioSalida.value;
    final duracion = controller.duracionSeleccionada.value;

    if (piso == null || lugar == null || auto == null || inicio == null || salida == null) {
      return false;
    }

    final monto = ((salida.difference(inicio).inMinutes / 60) * 10000).round();

    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar reserva"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Auto: ${auto.chapa} - ${auto.marca} ${auto.modelo}"),
            Text("Piso: ${piso.descripcion}"),
            Text("Lugar: ${lugar.descripcionLugar}"),
            Text("Inicio: ${UtilesApp.formatearFechaDdMMAaaa(inicio)} ${TimeOfDay.fromDateTime(inicio).format(context)}"),
            Text("Salida: ${UtilesApp.formatearFechaDdMMAaaa(salida)} ${TimeOfDay.fromDateTime(salida).format(context)}"),
            Text("Duración: ${duracion} h"),
            const SizedBox(height: 8),
            Text("Monto total: ${UtilesApp.formatearGuaranies(monto)}", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Confirmar")),
        ],
      ),
    ) ??
        false;
  }
}
