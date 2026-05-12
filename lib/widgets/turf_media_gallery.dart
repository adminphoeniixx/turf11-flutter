import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:video_player/video_player.dart';

import '../core/api_constants.dart';
import '../data/models/turf_model.dart';
import '../theme/app_theme.dart';
import 'shared_widgets.dart';

class TurfMediaGallery extends StatelessWidget {
  final TurfModel turf;

  const TurfMediaGallery({
    super.key,
    required this.turf,
  });

  @override
  Widget build(BuildContext context) {
    final media = [...turf.photos, ...turf.videos];
    if (media.isEmpty) {
      return const SizedBox.shrink();
    }

    return SmallCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Photos & Videos',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: media.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = media[index];
                final url = _resolvedUrl(item.url);
                if (item.type == TurfMediaType.video) {
                  return _VideoMediaTile(
                    url: url,
                    onTap: () => _openMediaViewer(context, media, index),
                  );
                }
                return _PhotoMediaTile(
                  url: url,
                  onTap: () => _openMediaViewer(context, media, index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoMediaTile extends StatelessWidget {
  final String url;
  final VoidCallback onTap;

  const _PhotoMediaTile({
    required this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 188,
          height: 132,
          color: AppColors.bg2,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _MediaError(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }
                  return const _MediaTileShimmer();
                },
              ),
              const _MediaBadge(icon: LucideIcons.image, label: 'Photo'),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoMediaTile extends StatefulWidget {
  final String url;
  final VoidCallback onTap;

  const _VideoMediaTile({
    required this.url,
    required this.onTap,
  });

  @override
  State<_VideoMediaTile> createState() => _VideoMediaTileState();
}

class _VideoMediaTileState extends State<_VideoMediaTile> {
  late final VideoPlayerController _controller;
  late final Future<void> _initializeVideo;

  @override
  void initState() {
    super.initState();
    final uri = Uri.parse(Uri.encodeFull(widget.url));
    _controller = VideoPlayerController.networkUrl(
      uri,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )..addListener(_refresh);
    _initializeVideo = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 188,
        height: 132,
        color: AppColors.dark,
        child: FutureBuilder<void>(
          future: _initializeVideo,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _MediaTileShimmer();
            }

            if (snapshot.hasError || _controller.value.hasError) {
              final error = snapshot.error?.toString().trim().isNotEmpty == true
                  ? snapshot.error.toString()
                  : _controller.value.errorDescription;
              return _VideoLoadError(error: error);
            }

            return GestureDetector(
              onTap: widget.onTap,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.62),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.play,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: Row(
                      children: [
                        _MediaBadge(
                          icon: LucideIcons.video,
                          label: 'Video',
                          positioned: false,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: AppColors.green,
                              bufferedColor: AppColors.muted2,
                              backgroundColor: Colors.white38,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }
}

class _MediaBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool positioned;

  const _MediaBadge({
    required this.icon,
    required this.label,
    this.positioned = true,
  });

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.58),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (!positioned) {
      return badge;
    }

    return Positioned(left: 8, bottom: 8, child: badge);
  }
}

class _VideoLoadError extends StatelessWidget {
  final String? error;

  const _VideoLoadError({this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg2,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            LucideIcons.alertCircle,
            color: AppColors.red,
            size: 22,
          ),
          const SizedBox(height: 6),
          Text(
            'Video unavailable',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
          if (error != null && error!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              error!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 9,
                color: AppColors.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MediaTileShimmer extends StatelessWidget {
  const _MediaTileShimmer();

  @override
  Widget build(BuildContext context) {
    return const ShimmerBox(
      width: 188,
      height: 132,
      borderRadius: BorderRadius.all(Radius.circular(12)),
    );
  }
}

class _MediaError extends StatelessWidget {
  const _MediaError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg2,
      child: const Center(
        child: Icon(
          LucideIcons.imageOff,
          color: AppColors.muted2,
          size: 24,
        ),
      ),
    );
  }
}

String _resolvedUrl(String rawUrl) {
  final value = rawUrl.trim();
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  if (value.startsWith('//')) {
    return 'https:$value';
  }

  final base = Uri.parse(ApiConstants.baseUrl);
  final origin = '${base.scheme}://${base.host}';
  if (value.startsWith('/')) {
    return '$origin$value';
  }
  return '$origin/$value';
}

Future<void> _openMediaViewer(
  BuildContext context,
  List<TurfMediaModel> media,
  int initialIndex,
) async {
  await Navigator.of(context).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _FullscreenMediaViewer(
        media: media,
        initialIndex: initialIndex,
      ),
    ),
  );
}

class _FullscreenMediaViewer extends StatefulWidget {
  final List<TurfMediaModel> media;
  final int initialIndex;

  const _FullscreenMediaViewer({
    required this.media,
    required this.initialIndex,
  });

  @override
  State<_FullscreenMediaViewer> createState() => _FullscreenMediaViewerState();
}

class _FullscreenMediaViewerState extends State<_FullscreenMediaViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.media[_currentIndex];
    final isVideo = current.type == TurfMediaType.video;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.media.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                final item = widget.media[index];
                final url = _resolvedUrl(item.url);
                if (item.type == TurfMediaType.video) {
                  return _FullscreenVideoPlayer(
                    url: url,
                    isActive: index == _currentIndex,
                  );
                }
                return _FullscreenPhoto(url: url);
              },
            ),
            Positioned(
              left: 12,
              top: 10,
              child: _MediaBadge(
                icon: isVideo ? LucideIcons.video : LucideIcons.image,
                label:
                    '${isVideo ? 'Video' : 'Photo'} ${_currentIndex + 1}/${widget.media.length}',
                positioned: false,
              ),
            ),
            Positioned(
              right: 12,
              top: 8,
              child: IconButton.filled(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(LucideIcons.x, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.dark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullscreenPhoto extends StatelessWidget {
  final String url;

  const _FullscreenPhoto({required this.url});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Image.network(
              url,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const _MediaError(),
              loadingBuilder: (context, child, progress) {
                if (progress == null) {
                  return child;
                }
                return const _FullscreenMediaShimmer();
              },
            ),
          ),
        );
      },
    );
  }
}

class _FullscreenVideoPlayer extends StatefulWidget {
  final String url;
  final bool isActive;

  const _FullscreenVideoPlayer({
    required this.url,
    required this.isActive,
  });

  @override
  State<_FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<_FullscreenVideoPlayer> {
  late final VideoPlayerController _controller;
  late final Future<void> _initializeVideo;

  @override
  void initState() {
    super.initState();
    final uri = Uri.parse(Uri.encodeFull(widget.url));
    _controller = VideoPlayerController.networkUrl(uri)
      ..addListener(_refresh);
    _initializeVideo = _controller.initialize().then((_) {
      _controller.setLooping(true);
      if (widget.isActive) {
        _controller.play();
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant _FullscreenVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive == widget.isActive ||
        !_controller.value.isInitialized) {
      return;
    }
    if (widget.isActive) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeVideo,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _FullscreenMediaShimmer();
        }

        if (snapshot.hasError || _controller.value.hasError) {
          final error = snapshot.error?.toString().trim().isNotEmpty == true
              ? snapshot.error.toString()
              : _controller.value.errorDescription;
          return Center(
            child: SizedBox(
              width: 260,
              child: _VideoLoadError(error: error),
            ),
          );
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio == 0
                    ? 16 / 9
                    : _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
            if (!_controller.value.isPlaying)
              IconButton.filled(
                onPressed: _togglePlayback,
                icon: const Icon(LucideIcons.play, size: 34),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.62),
                  foregroundColor: Colors.white,
                  fixedSize: const Size(68, 68),
                ),
              ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 22,
              child: Row(
                children: [
                  IconButton.filled(
                    onPressed: _togglePlayback,
                    icon: Icon(
                      _controller.value.isPlaying
                          ? LucideIcons.pause
                          : LucideIcons.play,
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.dark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: AppColors.green,
                        bufferedColor: AppColors.muted2,
                        backgroundColor: Colors.white38,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _togglePlayback() {
    if (!_controller.value.isInitialized) {
      return;
    }
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }
}

class _FullscreenMediaShimmer extends StatelessWidget {
  const _FullscreenMediaShimmer();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Center(
      child: ShimmerBox(
        width: size.width * 0.82,
        height: size.height * 0.36,
        borderRadius: const BorderRadius.all(Radius.circular(14)),
      ),
    );
  }
}
