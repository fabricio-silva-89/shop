import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:shop/models/order.dart';

class OrderWidget extends StatefulWidget {
  final Order order;

  const OrderWidget({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final itemsHeight = (widget.order.products.length * 24.0) + 10.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: expanded ? itemsHeight + 80 : 80,
      child: Card(
        child: Column(
          children: [
            ListTile(
              title: Text('R\$ ${widget.order.total.toStringAsFixed(2)}'),
              subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm').format(widget.order.date),
              ),
              trailing: IconButton(
                onPressed: () {
                  setState(() {
                    expanded = !expanded;
                  });
                },
                icon: const Icon(Icons.expand_more),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: expanded ? itemsHeight : 0,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              child: ListView(
                children: widget.order.products.map((product) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${product.quantity}x R\$ ${product.price}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
