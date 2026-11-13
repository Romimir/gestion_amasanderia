import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/order_model.dart';

class OrderViewModel extends ChangeNotifier {
  List<Order> _pedidos = [];
  bool _isLoading = false;

  List<Order> get pedidos => _pedidos;
  bool get isLoading => _isLoading;

  Future<void> cargarPedidos() async {
    _isLoading = true;
    notifyListeners();
    _pedidos = await DatabaseHelper.instance.getPedidos();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> agregarPedido(Order pedido) async {
    await DatabaseHelper.instance.insertPedido(pedido);
    await cargarPedidos();
  }

  Future<void> actualizarPedido(Order pedido) async {
    await DatabaseHelper.instance.updatePedido(pedido);
    await cargarPedidos();
  }

  Future<void> actualizarEstado(int id, String nuevoEstado) async {
    await DatabaseHelper.instance.updateEstadoEntrega(id, nuevoEstado);
    await cargarPedidos();
  }

  Future<void> eliminarPedido(int id) async {
    await DatabaseHelper.instance.deletePedido(id);
    await cargarPedidos();
  }
}