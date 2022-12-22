library overlay_lottie;

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Mixin that helps to overlay a Lottie animation over a content upon request (i.e. call of [showLottieOverlay], [showLottieOverlayDuring]
///   or [showLottieOverlayWhile]). It enables a control on the repetitions of the animation.
///
mixin OverlayLottie<T extends StatefulWidget> on TickerProviderStateMixin<T> {
  // The animation controller
  late final AnimationController _controller;

  // The animation is initially hidden
  bool _visible = false;

  // Internal value for the number of pending repetitions
  int? _repetitions;

  // Default number of repetitions, when calling [showLottieOverlay] method
  int _defaultNumberOfRepetitions = 1;

  // Default callback to call when hidding the lottie animation
  VoidCallback? _defaultOnHide;

  // Callback to call when hidding the image (to enable changing it when calling [showLottieOverlay])
  VoidCallback? _onHide;

  // An URL that enables to override the default animation
  String? _animationUrlOverride;

  // The object that enables the future to be resolved in different calls (e.g. when the object is hidden programmatically)
  late Completer<bool> _completer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          bool end = false;
          if (_repetitions != null) {
            _repetitions = _repetitions! - 1;
            if (_repetitions! > 0) {
              _controller.reset();
              _controller.forward();
            } else {
              end = true;
            }
          }
          if (end) {
            hideLottieOverlay();
          }
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Shortcut to show the animation during a [period].
  ///
  /// It returns true if the callback is started; false otherwise (i.e. if the animation is already shown)
  Future<bool> showLottieOverlayDuring(Duration period,
      {String? animationUrl, VoidCallback? onHide}) {
    return showLottieOverlayWhile(() async => await Future.delayed(period),
        onHide: onHide, animationUrl: animationUrl);
  }

  /// Shortcut to show the animation while a [callback] is executed. If provided, after [timeout] period, the execution
  ///   of [callback] will be aborted and (if provided), function [onTimeout] will be called.
  ///
  /// It returns true if the callback is started; false otherwise (i.e. if the animation is already shown)
  Future<bool> showLottieOverlayWhile(Function callback,
      {Duration? timeout,
      Function? onTimeout,
      String? animationUrl,
      VoidCallback? onHide}) async {
    if (_visible) {
      return false;
    }

    _showLottieOverlay(
        repetitions: double.maxFinite.toInt(),
        animationUrl: animationUrl,
        onHide: onHide);
    if (timeout == null) {
      await callback();
    } else {
      await callback().timeout(timeout, onTimeout: () async {
        if (onTimeout != null) {
          onTimeout();
        }
      });
    }

    hideLottieOverlay();
    return true;
  }

  Future<bool> showLottieOverlay(
      {bool? force,
      int? repetitions,
      String? animationUrl,
      VoidCallback? onHide}) async {
    if (!_showLottieOverlay(
        animationUrl: animationUrl,
        repetitions: repetitions,
        onHide: onHide,
        force: force ?? false)) {
      return false;
    }
    return _completer.future;
  }

  /// Shows the animation for [repetitions] time. If not provided, the amount of repetitions is the one provided during the
  ///   creation of the widget. If the animation is already shown, the state is not changed unless [forced] is set to true.
  bool _showLottieOverlay(
      {String? animationUrl,
      bool force = false,
      int? repetitions,
      VoidCallback? onHide}) {
    if (_visible && !force) {
      return false;
    }
    _completer = Completer();
    setState(() {
      _visible = true;
      _repetitions = repetitions ?? _defaultNumberOfRepetitions;
      _onHide = onHide ?? _defaultOnHide;
      _animationUrlOverride = animationUrl;
    });
    return true;
  }

  /// Stops the animation. If the animation is not being shown, the state is not changed unless [forced] is set to true.
  void hideLottieOverlay([bool force = false]) {
    if (!_visible && !force) {
      _completer.complete(false);
      return;
    }

    VoidCallback? onHide = _onHide ?? _defaultOnHide;

    setState(() {
      _visible = false;
      _repetitions = null;
      _onHide = null;
    });

    if (onHide != null) {
      onHide.call();
    }

    _completer.complete(true);
  }

  /// Builds the structure of the widget with an animation. The content shown is [child], but if the animation is being shown,
  ///   and [animationUrl] is provided, then a lottie animation is overlayed and the child is deactivated.
  ///
  /// If provided, the [durationPerRepetition] is set for each loop of the animation (i.e. to force that an animation loop
  ///   lasts a specific time); if not provided, the duration of each loop is the duration of the lottie object. When simply
  ///   shown an animation, it will be repeated for [defaultNumberOfRepetitions], unless a specific number of repetitions is
  ///   set when showing the animation.
  ///
  /// If the animation is being show, the content is blurred (if [blurContent] is set to true), and such content is also converted
  ///   to semi-transparent, according to the value of [opacity] (default: 0.8)
  ///
  Widget buildWithLottieOverlay(
      {required Widget child,
      String? animationUrl,
      Duration? durationPerRepetition,
      int defaultNumberOfRepetitions = 1,
      bool blurContent = false,
      double opacity = 0.8,
      VoidCallback? onHide}) {
    // Capture the parameters
    Widget content = child;
    _defaultNumberOfRepetitions = defaultNumberOfRepetitions;
    _defaultOnHide = onHide;

    // Override the default animation, if set
    animationUrl = _animationUrlOverride ?? animationUrl;
    _animationUrlOverride = null;

    // If the animation is visible and a URL has been provided, let's create the animation and the overlay
    if (_visible && (animationUrl != null)) {
      // Add opacity and blur (if requested)
      if (opacity != 1.0) {
        content = Opacity(opacity: 0.5, child: content);
      }
      if (blurContent) {
        content = ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: content,
        );
      }

      LottieBuilder? animation;

      // Create the animation, depending on the URL scheme (supported https or a string that represents the asset)
      if (animationUrl.startsWith("https://")) {
        animation = Lottie.network(
          animationUrl,
          repeat: false,
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = durationPerRepetition ?? composition.duration
              ..reset()
              ..forward();
          },
        );
      } else {
        animation = Lottie.asset(
          animationUrl,
          repeat: false,
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = durationPerRepetition ?? composition.duration
              ..reset()
              ..forward();
          },
        );
      }

      // Create the stack with the overlay
      content = Stack(
        children: [
          IgnorePointer(child: content),
          Center(child: animation),
        ],
      );
    }

    return content;
  }
}
