// products_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/product/product_bloc.dart';
import '../../blocs/product/product_event.dart';
import '../../blocs/product/product_state.dart';
import '../widgets/product_card.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadProducts());
  }

  Future<void> _onRefresh() {
    final bloc = context.read<ProductBloc>();
    final completer = Completer<void>();

    // Listen for success/failure to know when refresh finished
    final subscription = bloc.stream.listen((state) {
      if (state is ProductLoadSuccess || state is ProductLoadFailure) {
        if (!completer.isCompleted) completer.complete();
      }
    });

    // Fire the event
    bloc.add(LoadProducts());

    // Safety timeout so the refresh doesn't hang forever
    return completer.future
        .timeout(const Duration(seconds: 10), onTimeout: () {
      // on timeout just complete and cancel subscription
      if (!completer.isCompleted) completer.complete();
    }).whenComplete(() => subscription.cancel());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProductLoadSuccess) {
              final list = state.products;
              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) => ProductCard(product: list[index]),
                ),
              );
            } else if (state is ProductLoadFailure) {
              // Put the error inside a scrollable so RefreshIndicator can work
              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  // Use sized box to allow pull even when content is small
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - kToolbarHeight - 24,
                    child: Center(child: Text('Error: ${state.error}')),
                  ),
                ),
              );
            } else {
              // fallback: allow pull-to-refresh to trigger initial load
              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - kToolbarHeight - 24,
                    child: const Center(child: Text('No products')),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
