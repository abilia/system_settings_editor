import 'package:auth/bloc/authentication/authentication_bloc.dart';
import 'package:carymessenger/ui/pages/onboarding/connect_to_wifi/connect_to_wifi_page.dart';
import 'package:carymessenger/ui/pages/onboarding/login/login_page.dart';
import 'package:connectivity/connectivity_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Onboarding extends StatelessWidget {
  final Unauthenticated unauthenticatedState;
  const Onboarding({required this.unauthenticatedState, super.key});

  @override
  Widget build(BuildContext context) {
    final initial = _getPage(context.read<ConnectivityCubit>().state);
    final pageController = PageController(initialPage: initial);
    return BlocListener<ConnectivityCubit, ConnectivityState>(
      listener: (context, state) async {
        final page = _getPage(state);
        await pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuad,
        );
      },
      child: PageView(
        controller: pageController,
        children: [
          const ConnectToWifiPage(),
          LoginPage(unauthenticatedState: unauthenticatedState),
        ],
      ),
    );
  }

  int _getPage(ConnectivityState state) =>
      state.connectivityResult == ConnectivityResult.wifi ? 1 : 0;
}
