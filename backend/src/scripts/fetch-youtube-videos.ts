import axios from 'axios';
import { Video } from '../models';

require('dotenv').config();

const YOUTUBE_API_KEY = process.env.YOUTUBE_API_KEY ;

interface YouTubeChannel {
  handle: string;
  name: string;
}

const channels: YouTubeChannel[] = [
  { handle: '@learnwithrahim', name: 'Learn with Rahim' },
  { handle: '@learnwithkamran', name: 'Learn with Kamran' },
  { handle: '@learnwitharif', name: 'Learn with Arif' },
  { handle: '@learnwithsadiq', name: 'Learn with Sadiq' },
  { handle: '@learnwithhasib', name: 'Learn with Hasib' },
  { handle: '@learndigitalwithsam', name: 'Learn Digital with Sam' },
  { handle: '@learnwithfahim', name: 'Learn with Fahim' },
  { handle: '@learnwithmahin', name: 'Learn with Mahin' },
  { handle: '@learntocodewithali', name: 'Learn to Code with Ali' },
  { handle: '@learnwithfarhan', name: 'Learn with Farhan' },
];

async function getChannelIdFromHandle(handle: string): Promise<string | null> {
  try {
    const response = await axios.get(
      'https://www.googleapis.com/youtube/v3/search',
      {
        params: {
          key: YOUTUBE_API_KEY,
          q: handle,
          type: 'channel',
          part: 'snippet',
          maxResults: 1,
        },
      }
    );

    if (response.data.items && response.data.items.length > 0) {
      return response.data.items[0].snippet.channelId;
    }
    return null;
  } catch (error) {
    console.error(`Error fetching channel ID for ${handle}:`, error);
    return null;
  }
}

async function getChannelVideos(channelId: string, maxResults: number = 3) {
  try {
    const response = await axios.get(
      'https://www.googleapis.com/youtube/v3/search',
      {
        params: {
          key: YOUTUBE_API_KEY,
          channelId: channelId,
          part: 'snippet',
          order: 'date',
          maxResults: maxResults,
          type: 'video',
        },
      }
    );

    return response.data.items || [];
  } catch (error) {
    console.error(`Error fetching videos for channel ${channelId}:`, error);
    return [];
  }
}

async function getVideoDetails(videoIds: string[]) {
  try {
    const response = await axios.get(
      'https://www.googleapis.com/youtube/v3/videos',
      {
        params: {
          key: YOUTUBE_API_KEY,
          id: videoIds.join(','),
          part: 'contentDetails,statistics',
        },
      }
    );

    return response.data.items || [];
  } catch (error) {
    console.error('Error fetching video details:', error);
    return [];
  }
}

function parseDuration(duration: string): string {
  const match = duration.match(/PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?/);
  if (!match) return '0:00';

  const hours = parseInt(match[1] || '0');
  const minutes = parseInt(match[2] || '0');
  const seconds = parseInt(match[3] || '0');

  if (hours > 0) {
    return `${hours}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }
  return `${minutes}:${seconds.toString().padStart(2, '0')}`;
}

export async function fetchAndSeedYouTubeVideos() {
  console.log('🎬 Fetching videos from YouTube channels...\n');

  const allVideos: any[] = [];

  for (const channel of channels) {
    console.log(`📺 Processing ${channel.name} (${channel.handle})...`);

    // Get channel ID
    const channelId = await getChannelIdFromHandle(channel.handle);
    if (!channelId) {
      console.log(`   ❌ Could not find channel\n`);
      continue;
    }

    // Get latest videos
    const videos = await getChannelVideos(channelId, 1);
    if (videos.length === 0) {
      console.log(`   ⚠️  No videos found\n`);
      continue;
    }

    // Get video details
    const videoIds = videos.map((v: any) => v.id.videoId);
    const videoDetails = await getVideoDetails(videoIds);

    // Combine data
    for (let i = 0; i < videos.length; i++) {
      const video = videos[i];
      const details = videoDetails.find((d: any) => d.id === video.id.videoId);

      allVideos.push({
        videoId: video.id.videoId,
        title: video.snippet.title,
        channelName: channel.name,
        thumbnailUrl: video.snippet.thumbnails.high?.url || video.snippet.thumbnails.default.url,
        videoUrl: `https://www.youtube.com/watch?v=${video.id.videoId}`,
        duration: details ? parseDuration(details.contentDetails.duration) : '0:00',
        publishedDate: new Date(video.snippet.publishedAt),
        description: video.snippet.description,
        viewCount: details ? parseInt(details.statistics.viewCount || '0') : 0,
        likeCount: details ? parseInt(details.statistics.likeCount || '0') : 0,
      });
    }

    console.log(`   ✅ Fetched ${videos.length} video(s)\n`);

    // Add delay to avoid rate limiting
    await new Promise((resolve) => setTimeout(resolve, 1000));
  }

  console.log(`\n📊 Total videos fetched: ${allVideos.length}`);
  console.log('💾 Saving to database...\n');

  // Save to database
  for (const videoData of allVideos) {
    try {
      await Video.create({
        title: videoData.title,
        channelName: videoData.channelName,
        thumbnailUrl: videoData.thumbnailUrl,
        videoUrl: videoData.videoUrl,
        duration: videoData.duration,
        publishedDate: videoData.publishedDate,
        description: videoData.description || '',
        viewCount: videoData.viewCount,
        likeCount: videoData.likeCount,
      });
      console.log(`   ✅ Saved: ${videoData.title.substring(0, 50)}...`);
    } catch (error) {
      console.error(`   ❌ Error saving video: ${videoData.title}`, error);
    }
  }

  console.log('\n✅ YouTube video seeding completed!');
}

// Run if executed directly
if (require.main === module) {
  (async () => {
    const sequelize = require('../config/database').default;
    const { connectDatabase } = require('../config/database');

    await connectDatabase();
    await fetchAndSeedYouTubeVideos();
    await sequelize.close();
  })();
}
