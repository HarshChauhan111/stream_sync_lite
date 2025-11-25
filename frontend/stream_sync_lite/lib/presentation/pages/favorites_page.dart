import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/video/video_bloc.dart';
import '../bloc/video/video_event.dart';
import '../bloc/video/video_state.dart';
import '../../data/models/video_model.dart';
import 'video_player_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load favorites when page is first created
    _loadFavorites();
  }

  void _loadFavorites() {
    context.read<VideoBloc>().add(const VideoFavoritesLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return BlocBuilder<VideoBloc, VideoState>(
      builder: (context, state) {
        if (state is VideoLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is VideoError) {
          return _buildError(state.message);
        }

        if (state is VideoFavoritesLoaded) {
          if (state.favorites.isEmpty) {
            return _buildEmptyState();
          }
          return _buildFavoritesList(state.favorites);
        }

        // Initial state - show loading
        if (state is VideoInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Favorite Videos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Videos you mark as favorites will appear here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to home tab
              DefaultTabController.of(context)?.animateTo(0);
            },
            icon: const Icon(Icons.explore),
            label: const Text('Browse Videos'),
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
            onPressed: _loadFavorites,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(List<VideoModel> favorites) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadFavorites();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: favorites.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final video = favorites[index];
          return _buildVideoCard(video);
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
          ).then((_) {
            // Reload favorites when returning from video player
            _loadFavorites();
          });
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                Image.network(
                  video.thumbnailUrl,
                  width: 168,
                  height: 94,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 168,
                      height: 94,
                      color: Colors.grey[300],
                      child: const Icon(Icons.videocam, size: 40),
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
                      video.duration,
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
            
            // Video info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.channelName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.remove_red_eye, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${video.viewCount} views',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.thumb_up, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${video.likeCount}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Favorite button
            IconButton(
              icon: const Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              onPressed: () {
                context.read<VideoBloc>().add(
                  VideoFavoriteToggled(video.id),
                );
                // Show feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Removed from favorites'),
                    duration: Duration(seconds: 2),
                  ),
                );
                // Reload favorites after a short delay
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    _loadFavorites();
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
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
