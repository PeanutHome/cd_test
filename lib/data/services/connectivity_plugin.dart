import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/services/connectivity_gateway.dart';

class ConnectivityPlugin implements ConnectivityGateway {
  const ConnectivityPlugin(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isOnline async {
    final status = await _connectivity.checkConnectivity();
    return !status.contains(ConnectivityResult.none);
  }
}
