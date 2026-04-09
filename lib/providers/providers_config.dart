import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:meatshop_mobile/providers/auth/auth_provider.dart';

class ProvidersConfig {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
  ];
}
