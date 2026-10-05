import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Turns a decoded source image into the bitmap that will be displayed.
typedef ImageProcessor = Future<ui.Image> Function(ui.Image source);

/// Loads [url] (via the cached_network_image cache), runs [process] on it once and shows the
/// result with [RawImage]. Use this for effects that would otherwise run on every frame
/// (blur, clipping) — e.g. under a continuously animating player.
///
/// The previous bitmap stays visible until the next one is ready, so track changes don't flash.
class ProcessedNetworkImage extends StatefulWidget {
  const ProcessedNetworkImage({
    super.key,
    required this.url,
    required this.decodeWidth,
    required this.process,
    required this.placeholder,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.filterQuality = FilterQuality.medium,
  });

  final String url;

  /// Decode width in physical pixels.
  final int decodeWidth;
  final ImageProcessor process;
  final Widget placeholder;
  final double? width;
  final double? height;
  final BoxFit fit;
  final FilterQuality filterQuality;

  @override
  State<ProcessedNetworkImage> createState() => _ProcessedNetworkImageState();
}

class _ProcessedNetworkImageState extends State<ProcessedNetworkImage> {
  ui.Image? _image;
  ImageStream? _stream;
  ImageStreamListener? _listener;
  int _generation = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_stream == null) _resolve();
  }

  @override
  void didUpdateWidget(ProcessedNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url || oldWidget.decodeWidth != widget.decodeWidth) {
      _resolve();
    }
  }

  void _resolve() {
    _detach();
    final generation = ++_generation;
    final provider = ResizeImage(
      CachedNetworkImageProvider(widget.url),
      width: widget.decodeWidth,
    );
    final stream = provider.resolve(createLocalImageConfiguration(context));
    final listener = ImageStreamListener(
      (info, _) async {
        final ui.Image processed;
        try {
          processed = await widget.process(info.image);
        } finally {
          info.dispose();
        }
        if (!mounted || generation != _generation) {
          processed.dispose();
          return;
        }
        setState(() {
          _image?.dispose();
          _image = processed;
        });
      },
      onError: (_, __) {},
    );
    stream.addListener(listener);
    _stream = stream;
    _listener = listener;
  }

  void _detach() {
    final listener = _listener;
    if (listener != null) _stream?.removeListener(listener);
    _stream = null;
    _listener = null;
  }

  @override
  void dispose() {
    _detach();
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    if (image == null) return widget.placeholder;
    return RawImage(
      image: image,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      filterQuality: widget.filterQuality,
    );
  }
}
