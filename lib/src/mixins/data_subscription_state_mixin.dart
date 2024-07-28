import 'dart:async';

import 'package:flutter_data_sources/flutter_data_sources.dart';
import 'package:flutter/widgets.dart';

/// widget [State] mixin to automatically cancel all datasource subscription on widget dispose.
mixin DataSubscriptionStateMixin<T extends StatefulWidget> on State<T> {
  late final List<StreamSubscription> subs;

  /// list of [DataRepository] subscriptions.
  ///
  /// subscriptions will be created on [initState] and canceled on widget [dispose].
  Subs initSubscriptions();

  @override
  void initState() {
    subs = initSubscriptions();
    super.initState();
  }

  @override
  void dispose() {
    subs.cancel();
    super.dispose();
  }
}
