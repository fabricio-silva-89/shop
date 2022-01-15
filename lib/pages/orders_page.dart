import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/app_drawer.dart';
import 'package:shop/components/order_widget.dart';
import 'package:shop/models/order_list.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({Key? key}) : super(key: key);

  // Future<void> _refreseOrders(BuildContext context) {
  //   return Provider.of<OrderList>(
  //     context,
  //     listen: false,
  //   ).loadOrders();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<OrderList>(context, listen: false).loadOrders(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Consumer<OrderList>(
              builder: (ctx, orders, child) => ListView.builder(
                itemCount: orders.itemsCount,
                itemBuilder: (ctx, i) {
                  return OrderWidget(order: orders.items[i]);
                },
              ),
            );
          }
        },
      ),
      // body: isLoading
      //     ? const Center(
      //         child: CircularProgressIndicator(),
      //       )
      //     : RefreshIndicator(
      //         onRefresh: () => _refreseOrders(context),
      //         child: ListView.builder(
      //           itemCount: orders.itemsCount,
      //           itemBuilder: (ctx, i) {
      //             return OrderWidget(order: orders.items[i]);
      //           },
      //         ),
      //       ),
    );
  }
}
