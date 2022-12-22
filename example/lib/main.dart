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

class _LottieOverlayHomeState extends State<LottieOverlayHome> with TickerProviderStateMixin, OverlayLottie {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: buildWithLottieOverlay(context, 
          animationUrl: "https://assets6.lottiefiles.com/packages/lf20_fj8rlma5.json",
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                        onPressed: () => showLottieOverlay(repetitions: 1),
                        child: const Text("show Lottie")
                      ),
                ElevatedButton(
                        onPressed: () {
                          showLottieOverlayWhile(
                            () async {
                              await Future.delayed(const Duration(seconds: 3));
                            },  
                            animationUrl: "https://assets6.lottiefiles.com/packages/lf20_z3pnisgt.json", 
                          ).then((value) {
                            showLottieOverlay(animationUrl: "https://assets8.lottiefiles.com/packages/lf20_slGFhN.json");
                          });
                        },
                        child: const Text("simulate login")
                      ),
              ],
            ),
          )
          /*
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  Text("Overlay Lottie\nDemo", style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
                  const SizedBox(height: 16,),
                  ElevatedButton(onPressed: () {
                      showLottieOverlay(repetitions: 1);
                    },
                    child: const Text("show Lottie 1 repetition")
                  ),
                  ElevatedButton(onPressed: () {
                      showLottieOverlay(repetitions: 3, onHide: () {
                        print("run 3 times");
                      },);
                    },
                    child: const Text("show Lottie 3 repetitions")
                  ),
                  ElevatedButton(onPressed: () {
                      print(showLottieOverlayDuring(const Duration(seconds: 2)));
                      print("continuo");
                    },
                    child: const Text("show Lottie for 2 seconds")
                  ),
                  ElevatedButton(onPressed: () {
                      showLottieOverlayWhile(() async {
                        await Future.delayed(const Duration(seconds: 5));
                      }, ).then((value) { if (value) print("closed after 5 seconds"); });
                    },
                    child: const Text("show Lottie during the execution of a function")
                  ),
                ]
            )
          )*/
        ),
      );
  }
}
