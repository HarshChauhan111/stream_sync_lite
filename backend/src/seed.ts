import sequelize from './config/database';
import { Video } from './models';

const sampleVideos = [
  {
    title: 'Big Buck Bunny',
    channelName: 'Blender Foundation',
    thumbnailUrl: 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    duration: '9:56',
    publishedDate: new Date('2024-01-15'),
    description: 'Big Buck Bunny tells the story of a giant rabbit with a heart bigger than himself. When one sunny day three rodents rudely harass him, something snaps... and the rabbit ain\'t no bunny anymore!',
    viewCount: 15420,
    likeCount: 1250,
  },
  {
    title: 'Elephant Dream',
    channelName: 'Orange Open Movie Project',
    thumbnailUrl: 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    duration: '10:53',
    publishedDate: new Date('2024-01-20'),
    description: 'The first Blender Open Movie from 2006. Two strange characters explore a surreal world.',
    viewCount: 28540,
    likeCount: 2100,
  },
  {
    title: 'For Bigger Blazes',
    channelName: 'Google Android',
    thumbnailUrl: 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    duration: '0:15',
    publishedDate: new Date('2024-02-01'),
    description: 'HDR demo video showcasing vibrant colors and high dynamic range.',
    viewCount: 19820,
    likeCount: 1580,
  },
  {
    title: 'For Bigger Escape',
    channelName: 'Google Android',
    thumbnailUrl: 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    duration: '0:15',
    publishedDate: new Date('2024-02-10'),
    description: 'Beautiful aerial views and outdoor adventure scenes in stunning HD quality.',
    viewCount: 42150,
    likeCount: 3420,
  },
  {
    title: 'For Bigger Fun',
    channelName: 'Google Android',
    thumbnailUrl: 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerFun.jpg',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    duration: '0:15',
    publishedDate: new Date('2024-02-15'),
    description: 'Fun and vibrant scenes perfect for testing video playback quality.',
    viewCount: 31250,
    likeCount: 2650,
  },
  {
    title: 'For Bigger Joyrides',
    channelName: 'Google Android',
    thumbnailUrl: 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerJoyrides.jpg',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    duration: '0:15',
    publishedDate: new Date('2024-02-20'),
    description: 'High-quality video showcasing exciting rides and adventure.',
    viewCount: 25480,
    likeCount: 1950,
  },
  {
    title: 'For Bigger Meltdowns',
    channelName: 'Google Android',
    thumbnailUrl: 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerMeltdowns.jpg',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
    duration: '0:15',
    publishedDate: new Date('2024-02-25'),
    description: 'Demo video featuring dynamic action and vibrant visuals.',
    viewCount: 38920,
    likeCount: 3180,
  },
  {
    title: 'Sintel',
    channelName: 'Blender Foundation',
    thumbnailUrl: 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/Sintel.jpg',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    duration: '14:48',
    publishedDate: new Date('2024-03-01'),
    description: 'A lonely young woman, Sintel, helps and befriends a dragon, whom she calls Scales. But when he is kidnapped by an adult dragon, Sintel decides to embark on a dangerous quest to find her lost friend.',
    viewCount: 29650,
    likeCount: 2340,
  },
  {
    title: 'Subaru Outback On Street And Dirt',
    channelName: 'Garage419',
    thumbnailUrl: 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/SubaruOutbackOnStreetAndDirt.jpg',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
    duration: '0:48',
    publishedDate: new Date('2024-03-05'),
    description: 'Driving the Subaru Outback on both street and dirt terrain, showcasing its versatility.',
    viewCount: 45280,
    likeCount: 3890,
  },
  {
    title: 'Tears of Steel',
    channelName: 'Blender Foundation',
    thumbnailUrl: 'https://storage.googleapis.com/gtv-videos-bucket/sample/images/TearsOfSteel.jpg',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    duration: '12:14',
    publishedDate: new Date('2024-03-10'),
    description: 'A sci-fi action short film by the Blender Foundation. In an apocalyptic future, a group of soldiers and scientists take refuge in Amsterdam to try to stop an army of robots.',
    viewCount: 33520,
    likeCount: 2780,
  },
];

async function seedVideos() {
  try {
    console.log('🌱 Starting database seed...');

    // Connect to database
    await sequelize.authenticate();
    console.log('✅ Database connection established');

    // Sync models (create tables if they don't exist)
    await sequelize.sync({ alter: true });
    console.log('✅ Database models synchronized');

    // Check if videos already exist
    const existingCount = await Video.count();
    if (existingCount > 0) {
      console.log(`⚠️  Database already contains ${existingCount} videos. Skipping seed.`);
      console.log('   Run with --force to re-seed (this will delete existing videos)');
      process.exit(0);
    }

    // Insert sample videos
    await Video.bulkCreate(sampleVideos);
    console.log(`✅ Successfully seeded ${sampleVideos.length} videos`);

    // Display summary
    const totalVideos = await Video.count();
    console.log(`\n📊 Database Summary:`);
    console.log(`   Total Videos: ${totalVideos}`);

    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  }
}

// Handle force flag
const forceFlag = process.argv.includes('--force');

if (forceFlag) {
  console.log('⚠️  Force flag detected. Will delete existing data...');
  Video.destroy({ where: {}, truncate: true })
    .then(() => {
      console.log('✅ Existing videos deleted');
      seedVideos();
    })
    .catch((error) => {
      console.error('❌ Error deleting videos:', error);
      process.exit(1);
    });
} else {
  seedVideos();
}
