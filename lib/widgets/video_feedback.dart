import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

class VideoFeedback extends HookWidget {
  const VideoFeedback({
    Key key,
    this.streamUrl,
    this.height,
    this.width,
  }) : super(key: key);

  final String streamUrl;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final isRunning = useState(true);
    return Mjpeg(
      height: height != null ? height : null,
      width: width != null ? width : null,
      fit: BoxFit.cover,
      isLive: isRunning.value,
      stream: streamUrl != null ? streamUrl : null,
    );
  }
}
