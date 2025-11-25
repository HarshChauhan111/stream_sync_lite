import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/video/video_bloc.dart';
import '../bloc/video/video_event.dart';
import '../bloc/video/video_state.dart';

import '../../data/models/video_model.dart';
import 'video_player_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    print('🏠 HomePage initState called');
    // Load videos on init
    print('📹 Dispatching VideoLoadRequested event...');
    context.read<VideoBloc>().add(const VideoLoadRequested());
    
    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);
    print('✅ HomePage initialized');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<VideoBloc>().add(const VideoLoadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _handleVideoMenuAction(String action, VideoModel video) {
    switch (action) {
      case 'favorite':
        context.read<VideoBloc>().add(VideoFavoriteToggled(video.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              video.isFavorite
                  ? 'Removed from favorites'
                  : 'Added to favorites',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        break;
      case 'details':
        _showVideoDetails(video);
        break;
      case 'share':
        _shareVideo(video);
        break;
    }
  }

  void _showVideoDetails(VideoModel video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                video.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.person, 'Channel', video.channelName),
              _buildDetailRow(Icons.remove_red_eye, 'Views', '${video.viewCount}'),
              _buildDetailRow(Icons.thumb_up, 'Likes', '${video.likeCount}'),
              _buildDetailRow(Icons.access_time, 'Duration', video.duration),
              _buildDetailRow(
                Icons.calendar_today,
                'Published',
                _formatDate(video.publishedDate),
              ),
              if (video.description != null && video.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(video.description!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  void _shareVideo(VideoModel video) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share: ${video.title}'),
        action: SnackBarAction(
          label: 'COPY LINK',
          onPressed: () {
            // In real app, copy video.videoUrl to clipboard
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Today';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<VideoBloc, VideoState>(
        builder: (context, state) {
          if (state is VideoLoading) {
            return _buildLoadingGrid();
          }

          if (state is VideoError) {
            return _buildError(state.message);
          }

          if (state is VideoLoaded) {
            if (state.videos.isEmpty) {
              return _buildEmpty();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<VideoBloc>().add(const VideoLoadRequested(refresh: true));
              },
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: state.videos.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.videos.length) {
                    return _buildLoadingCard();
                  }
                  return _buildVideoCard(state.videos[index]);
                },
              ),
            );
          }

          if (state is VideoFavoritesLoaded) {
            return _buildFavoritesList(state.favorites);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildVideoCard(VideoModel video) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerPage(video: video),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.videocam, size: 50),
                      );
                    },
                  ),
                  // Duration badge
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDuration(video.duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  // Progress indicator
                  if (video.lastPlayedPosition > 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        value: video.lastPlayedPosition / _durationToSeconds(video.duration),
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    ),
                ],
              ),
            ),
            // Video info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            video.channelName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: IconButton(
                            icon: Icon(
                              video.isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: video.isFavorite ? Colors.red : null,
                            ),
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              context.read<VideoBloc>().add(
                                VideoFavoriteToggled(video.id),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 18),
                            padding: EdgeInsets.zero,
                            iconSize: 18,
                            onSelected: (value) => _handleVideoMenuAction(value, video),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'favorite',
                                child: Row(
                                  children: [
                                    Icon(
                                      video.isFavorite ? Icons.favorite : Icons.favorite_border,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(video.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'details',
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, size: 20),
                                    SizedBox(width: 12),
                                    Text('View Details'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'share',
                                child: Row(
                                  children: [
                                    Icon(Icons.share, size: 20),
                                    SizedBox(width: 12),
                                    Text('Share'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _buildLoadingCard(),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[300],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 14,
                    width: double.infinity * 0.7,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: $message',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<VideoBloc>().add(const VideoLoadRequested(refresh: true));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No videos available',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<VideoBloc>().add(const VideoLoadRequested(refresh: true));
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(List<VideoModel> favorites) {
    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No favorites yet',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<VideoBloc>().add(const VideoLoadRequested(refresh: true));
              },
              child: const Text('Browse Videos'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) => _buildVideoCard(favorites[index]),
    );
  }

  String _formatDuration(String duration) {
    // Duration is already in string format like "10:25" or "1:30:15"
    return duration;
  }

  int _durationToSeconds(String duration) {
    final parts = duration.split(':');
    if (parts.length == 3) {
      // HH:MM:SS
      return int.parse(parts[0]) * 3600 + int.parse(parts[1]) * 60 + int.parse(parts[2]);
    } else if (parts.length == 2) {
      // MM:SS
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    } else {
      return 0;
    }
  }
}
