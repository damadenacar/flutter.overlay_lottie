# Overlay Lottie animation

Showing interactivity is important for apps, even while executing blocking tasks like logging in, greeting successful tasks or notifying events. During these periods it is possible to show a fancy animation using the amazing [Lottie Files](https://lottiefiles.com/).

Although it is easy to show build and show an animation, depending on the state of a _StatefulWidget_, it is easier not to have to build it ;) And it is better if it is not needed to control when to stop showing an animation (e.g. when the animation ends, it has been repeated a specific number of times, or even if the task for which the animation has been shown has ended).

This package provides a mixin that eases the task of overlaying a Lottie animation over an arbitrary widget, to show activity during the execution of long tasks.

## Features

The basic features of this mixing, where used in a widget are:

1. Show a Lottie animation from the beginning of the animation to the end (i.e. 1 repetition)

    ![Overlay Lottie animation 1 repetition ](https://github.com/damadenacar/flutter.overlay_lottie/raw/main/img/overlay_lottie_1rep.gif)

1. Show a Lottie animation from the beginning of the animation to the end (i.e. a repetition)

    ![Overlay Lottie animation 3 repetitions ](https://github.com/damadenacar/flutter.overlay_lottie/raw/main/img/overlay_lottie_3reps.gif)

1. Show a Lottie animation for a limited time (e.g. 2 seconds)

    ![Overlay Lottie animation 2 seconds ](https://github.com/damadenacar/flutter.overlay_lottie/raw/main/img/overlay_lottie_2secs.gif)

1. Show a Lottie animation during the execution of a function

    ![Overlay Lottie animation during the execution of a function](https://github.com/damadenacar/flutter.overlay_lottie/raw/main/img/overlay_lottie_function.gif)

## Getting started

To start using this package, add it to your `pubspec.yaml` file:

```yaml
dependencies:
    overlay_lottie:
```

Then get the dependencies (e.g. `flutter pub get`) and import them into your application:

```dart
import 'package:overlay_lottie/overlay_lottie.dart';
```

## Usage

You need to add the mixin to your `StatefulWidget` along with the `TickerProviderStateMixin` mixin, and then use the function `buildWithLottieOverlay` in your `build` override:

```dart
class _LottieOverlayHomeState extends State<LottieOverlayHome> with TickerProviderStateMixin, OverlayLottie {
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: null,
            body: buildWithLottieOverlay(
                animationUrl: "https://assets6.lottiefiles.com/packages/lf20_fj8rlma5.json",
            ),
            child: Center(
                child: ElevatedButton(
                    onPressed: () => showLottieOverlay(repetitions: 1),
                    child: const Text("show Lottie")
                )
            )
        );
    }
}
```

That produces the next application:

![Simple demo application](https://github.com/damadenacar/flutter.overlay_lottie/raw/main/img/overlay_lottie_simple.gif)

## Additional information

There are different mechanisms and options to control how and when to show the overlay: showing the animation until it is programmatically hidden (i.e. `showLottieOverlay` ... `hideLottieOverlay`), showing the animation while a function is being run, or showing the animation during a period.

The interface of the function to build the overlay is the next:

```dart
Widget buildWithLottieOverlay({ 
      required Widget child, 
      String? animationUrl, 
      Duration? durationPerRepetition, 
      int defaultNumberOfRepetitions = 1, 
      bool blurContent = false, 
      double opacity = 0.8,
      VoidCallback? onHide
    })
```

The function somehow defines the default values for the process, but some of them may be overridden when showing the animation.

- __`child`:__ the content to show under the overlay.
- __`animationUrl`:__ the string that points to the Lottie file. If it starts with `https://` or `http://`, it will be created using `Lottie.network`. Otherwise, it will be interpreted as an asset and thus is created using `Lottie.asset`.
- __`durationPerRepetition`:__ The duration of each repetition. This is useful if you have an animation of (e.g. 4 seconds), but you want it to run in 2 seconds.
- __`defaultNumberOfRepetitions` (defaults to 1):__ When showing the animation using `showLottieOverlay`, the number of repetitions that the animation has to be shown before it autocloses. If wanted to not to auto-close the animation and continue repeating it until `hideLottieOverlay` is called, please set this to `double.maxFinite.toInt()`.
- __`blurContent` (defaults to false):__ If set to `true`, the child widget will be blurred (to give the feeling of being non-interactive).
- __`opacity` (defaults to 0.8):__ If set to a value different than 1, the child widget will be set to semi-transparent by this factor.
- __`onHide`:__ Callback to call whenever the animation is hidden (whether auto-closed or closed using `hideLottieOverlay` function)

### Showing the overlay

There are multiple functions to show the overlay:

```dart
Future<bool> showLottieOverlay({bool? force, int? repetitions, String? animationUrl, VoidCallback? onHide})
```

This is the basic function that shows the animation `animationUrl` for a number of `repetitions`, and calls function `onHide` when the animation is hidden. If `repetitions`, `animationUrl` or `onHide` are not provided, they default to the values provided in the call to `buildWithLottieOverlay`.

If the animation was already being shown, the state of the widget will not change, and `onHide` will not be called. This happens unless the parameter `force` is set to `true`.

It is set as a `Future<bool>` to enable chaining function execution (e.g. using `then`). The result that receives the future refers to wether the animation has been shown or not (i.e. `true`) or it was already being shown (i.e. `false`).


```dart
void hideLottieOverlay([bool force = false])
```

This function hides the overlay and enables the usage of the child widget again. The function is intended to be called after `showLottieOverlay` is called, but it is advisable to use the _auto-close_ feature (e.g. running the animation for a number of loops, or while the execution of a function).

If the animation was already hidden, the state of the widget will not change, unless the parameter `force` is set to `true`.

```dart
Future<bool> showLottieOverlayWhile(Function callback, {String? animationUrl,Duration? timeout, Function? onTimeout, VoidCallback? onHide})
```

This function shows the Lottie animation `animationUrl` during the execution of `callback`. It is possible to set a `timeout` for the execution. If the time for the execution exceeds that time, the execution of the `callback` is aborted, and the function `onTimeout` is called.

If `animationUrl` or `onHide` are not provided, they default to the values provided in the call to `buildWithLottieOverlay`.

The function returns a `Future<bool>` that is resolved after the callback is executed (or aborted). So it is possible to chain it with other functions using `await` or `then` procedures. This procedure is independent from the `onHide` callback, and so both `onHide` may be called and the chain to `then` may be executed.

The `bool` result is set to `true` is the animation has been shown and hidden. If the animations was already shown when calling `showLottieOverlayWhile` the result of the _future_ will be set to `false`.

```dart
Future<bool> showLottieOverlayDuring(Duration period, {String? animationUrl, VoidCallback? onHide });
```

This function shows the Lottie animation `animationUrl` during the period `period`. If `animationUrl` or `onHide` are not provided, they default to the values provided in the call to `buildWithLottieOverlay`.

At the end, this is a shortcut for `return showLottieOverlayWhile(() async => await Future.delayed(period), onHide: onHide, animationUrl: animationUrl)`.

