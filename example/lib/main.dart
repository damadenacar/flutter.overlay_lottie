import 'package:flutter/material.dart';
import 'package:overlay_lottie/overlay_lottie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Overlay Lottie Demo',
      home: LottieOverlayHome(),
    );
  }
}

class LottieOverlayHome extends StatefulWidget {
  const LottieOverlayHome({super.key});

  @override
  State<LottieOverlayHome> createState() => _LottieOverlayHomeState();
}

class _LottieOverlayHomeState extends State<LottieOverlayHome>
    with TickerProviderStateMixin, OverlayLottie {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: buildWithLottieOverlay(
          animationUrl:
              "https://assets6.lottiefiles.com/packages/lf20_fj8rlma5.json",
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () => showLottieOverlay(repetitions: 1),
                    child: const Text("show Lottie")),
                ElevatedButton(
                    onPressed: () {
                      showLottieOverlayWhile(
                        () async {
                          await Future.delayed(const Duration(seconds: 3));
                        },
                        animationUrl:
                            "https://assets6.lottiefiles.com/packages/lf20_z3pnisgt.json",
                      ).then((value) {
                        showLottieOverlay(
                            animationUrl:
                                "https://assets8.lottiefiles.com/packages/lf20_slGFhN.json");
                      });
                    },
                    child: const Text("simulate login")),
              ],
            ),
          )),
    );
  }
}
