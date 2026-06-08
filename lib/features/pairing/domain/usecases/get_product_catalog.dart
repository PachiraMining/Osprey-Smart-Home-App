import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/osprey_product.dart';
import '../repositories/pairing_repository.dart';

class GetProductCatalog {
  final PairingRepository repository;
  GetProductCatalog(this.repository);

  Future<Either<Failure, List<OspreyProduct>>> call(
          {bool forceRefresh = false}) =>
      repository.getProductCatalog(forceRefresh: forceRefresh);
}
