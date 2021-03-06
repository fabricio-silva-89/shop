import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';
import 'package:shop/models/product_list.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({Key? key}) : super(key: key);

  @override
  _ProductFormPageState createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final priceFocus = FocusNode();
  final descriptionFocus = FocusNode();
  final imageUrlFocus = FocusNode();
  final imageUrlController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final formData = <String, Object>{};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    imageUrlFocus.addListener(updateImage);
  }

  @override
  void dispose() {
    super.dispose();
    priceFocus.dispose();
    descriptionFocus.dispose();
    imageUrlFocus.dispose();
    imageUrlFocus.removeListener(updateImage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (formData.isEmpty) {
      final arg = ModalRoute.of(context)?.settings.arguments;

      if (arg != null) {
        final product = arg as Product;
        formData['id'] = product.id;
        formData['name'] = product.name;
        formData['description'] = product.description;
        formData['price'] = product.price;
        formData['imageUrl'] = product.imageUrl;

        imageUrlController.text = product.imageUrl;
      }
    }
  }

  void updateImage() {
    setState(() {});
  }

  bool isValidImageUrl(String url) {
    bool isValidUrl = Uri.tryParse(url)?.hasAbsolutePath ?? false;
    bool endsWithFile = url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg');

    return isValidUrl && endsWithFile;
  }

  Future<void> submitForm() async {
    final isValid = formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    formKey.currentState?.save();

    setState(() => isLoading = true);

    try {
      await Provider.of<ProductList>(
        context,
        listen: false,
      ).saveProduct(formData);

      Navigator.of(context).pop();
    } catch (error) {
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Ocorreu um erro'),
            content: const Text('Ocorreu um erro ao salvar um produto!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formul??rio de Produto'),
        actions: [
          IconButton(
            onPressed: submitForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: formData['name'].toString(),
                      decoration: const InputDecoration(labelText: 'Nome'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(priceFocus),
                      onSaved: (name) => formData['name'] = name ?? '',
                      validator: (value) {
                        final name = value ?? '';

                        if (name.trim().isEmpty) {
                          return 'Nome ?? obrigat??rio';
                        }

                        if (name.trim().length < 3) {
                          return 'Nome precisa no m??nimo de 3 letras';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: formData['price'].toString(),
                      decoration: const InputDecoration(labelText: 'Pre??o'),
                      textInputAction: TextInputAction.next,
                      focusNode: priceFocus,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(descriptionFocus),
                      onSaved: (price) =>
                          formData['price'] = double.parse(price ?? '0'),
                      validator: (value) {
                        final priceString = value ?? '';
                        final price = double.tryParse(priceString) ?? -1;

                        if (price <= 0) {
                          return 'Informe um pre??o v??lido';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: formData['description'].toString(),
                      decoration: const InputDecoration(labelText: 'Descri????o'),
                      focusNode: descriptionFocus,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      onSaved: (description) =>
                          formData['description'] = description ?? '',
                      validator: (value) {
                        final description = value ?? '';

                        if (description.trim().isEmpty) {
                          return 'Descricao ?? obrigat??rio';
                        }

                        if (description.trim().length < 10) {
                          return 'Nome precisa no m??nimo de 10 letras';
                        }

                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Url da Imagem'),
                            focusNode: imageUrlFocus,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: imageUrlController,
                            onFieldSubmitted: (_) => submitForm(),
                            onSaved: (imageUrl) =>
                                formData['imageUrl'] = imageUrl ?? '',
                            validator: (value) {
                              final imageUrl = value ?? '';

                              if (!isValidImageUrl(imageUrl)) {
                                return 'Informe uma Url v??lida';
                              }

                              return null;
                            },
                          ),
                        ),
                        Container(
                          height: 100,
                          width: 100,
                          margin: const EdgeInsets.only(
                            top: 10,
                            left: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: imageUrlController.text.isEmpty
                              ? const Text('Informe a Url')
                              : Image.network(imageUrlController.text),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
