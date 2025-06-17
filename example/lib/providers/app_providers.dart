// lib/providers/app_providers.dart
import 'package:provider/single_child_widget.dart';

import 'core_providers.dart';
import 'feature_providers.dart';

List<SingleChildWidget> appProviders = [
  ...coreProviders,
  ...featureProviders,
];
