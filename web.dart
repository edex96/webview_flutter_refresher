import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewRefresher extends StatefulWidget {
  const WebviewRefresher({super.key, required this.controller});
  final WebViewController controller;
  @override
  State<WebviewRefresher> createState() => _WebviewRefresherState();
}

class _WebviewRefresherState extends State<WebviewRefresher> {
  final scrollController = ScrollController();
  final currentOffset = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    widget.controller.setOnScrollPositionChange((change) {
      currentOffset.value = change.y;
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    currentOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator.adaptive(
          onRefresh: () async {
            widget.controller.reload();
          },
          child: SingleChildScrollView(
            controller: scrollController,
            child: SizedBox(
              height: constraints.maxHeight,
              child: WebViewWidget(
                controller: widget.controller,
                gestureRecognizers: {
                  Factory(
                    () => WebviewGestureRecognizer(
                      scrollController: scrollController,
                      context: context,
                      offset: currentOffset,
                    ),
                  ),
                },
              ),
            ),
          ),
        );
      },
    );
  }
}


class WebviewGestureRecognizer extends VerticalDragGestureRecognizer {
  WebviewGestureRecognizer({
    required this.offset,
    required this.scrollController,
    required this.context,
    super.debugOwner,
    super.allowedButtonsFilter,
  }) : super(
          supportedDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.mouse,
          },
        );

  final ScrollController scrollController;
  final BuildContext context;
  final ValueNotifier<double> offset;

  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }

  Drag? _drag;
  bool _firstDirectionIsUp = false;

  @override
  GestureDragStartCallback? get onStart => (details) {
        _firstDirectionIsUp = false;
        if (offset.value <= 0) {
          _drag = scrollController.position.drag(details, () {
            _drag = null;
          });
        } else {
          _drag = null;
        }
      };

  @override
  GestureDragUpdateCallback? get onUpdate => (details) {
        if (details.delta.direction < 0 && !_firstDirectionIsUp) {
          _firstDirectionIsUp = true;
          _drag?.end(DragEndDetails(primaryVelocity: 0));
          _drag = null;
          return;
        } else {
          _firstDirectionIsUp = true;
        }
        _drag?.update(details);
      };

  @override
  GestureDragEndCallback? get onEnd => (details) {
        _drag?.end(details);
        _drag = null;
      };
}
