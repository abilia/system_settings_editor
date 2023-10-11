import 'package:auth/bloc/base_url/base_url_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repository_base/end_point.dart';

class BackendBanner extends StatelessWidget {
  const BackendBanner({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final backend =
        context.select((BaseUrlCubit cubit) => backendName(cubit.state));
    if (backend == prodName) return child;
    return Banner(
      message: backend,
      location: BannerLocation.topStart,
      color: Colors.blueGrey,
      child: child,
    );
  }
}
