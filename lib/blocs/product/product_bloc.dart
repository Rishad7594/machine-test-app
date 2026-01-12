import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;
  ProductBloc({required this.productRepository}) : super(ProductInitial()) {
    on<LoadProducts>((event, emit) async {
      emit(ProductLoadInProgress());
      try {
        final products = await productRepository.getProducts();
        emit(ProductLoadSuccess(products));
      } catch (e) {
        emit(ProductLoadFailure(e.toString()));
      }
    });
  }
}