import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop/components/product_grid.dart';
import 'package:shop/models/product_list.dart';

enum FilterOption { favorite, all }

class ProductsOverviewPage extends StatelessWidget {
  const ProductsOverviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductList>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Loja'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => const [
              PopupMenuItem(
                child: Text('Somente Favoritos'),
                value: FilterOption.favorite,
              ),
              PopupMenuItem(
                child: Text('Todos'),
                value: FilterOption.all,
              ),
            ],
            onSelected: (selectedValue) {
              if (selectedValue == FilterOption.favorite) {
                provider.showFavoriteOnly();
              } else {
                provider.showAll();
              }
            },
          ),
        ],
      ),
      body: const ProductGrid(),
    );
  }
}
