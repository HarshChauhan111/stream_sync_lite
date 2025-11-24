import sequelize from './config/database';
import { Video } from './models';

const sampleVideos = [
  {
    title: 'Introduction to Flutter Development',
    channelName: 'Flutter Academy',
    thumbnailUrl: 'https://picsum.photos/seed/video1/640/360',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    duration: '9:56',
    publishedDate: new Date('2024-01-15'),
    description: 'Learn the basics of Flutter development in this comprehensive tutorial.',
    viewCount: 15420,
    likeCount: 1250,
  },
  {
    title: 'Node.js Backend Best Practices',
    channelName: 'Dev Masters',
    thumbnailUrl: 'https://picsum.photos/seed/video2/640/360',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    duration: '15:32',
    publishedDate: new Date('2024-01-20'),
    description: 'Discover the best practices for building scalable Node.js applications.',
    viewCount: 28540,
    likeCount: 2100,
  },
  {
    title: 'Understanding Firebase Push Notifications',
    channelName: 'Mobile Dev Tips',
    thumbnailUrl: 'https://picsum.photos/seed/video3/640/360',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    duration: '12:45',
    publishedDate: new Date('2024-02-01'),
    description: 'Complete guide to implementing Firebase Cloud Messaging in your mobile apps.',
    viewCount: 19820,
    likeCount: 1580,
  },
  {
    title: 'React vs Flutter: Which to Choose?',
    channelName: 'Tech Insights',
    thumbnailUrl: 'https://picsum.photos/seed/video4/640/360',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    duration: '18:20',
    publishedDate: new Date('2024-02-10'),
    description: 'A detailed comparison between React Native and Flutter for cross-platform development.',
    viewCount: 42150,
    likeCount: 3420,
  },
  {
    title: 'Database Design Fundamentals',
    channelName: 'Database Pro',
    thumbnailUrl: 'https://picsum.photos/seed/video5/640/360',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    duration: '22:10',
    publishedDate: new Date('2024-02-15'),
    description: 'Master the fundamentals of database design with real-world examples.',
    viewCount: 31250,
    likeCount: 2650,
  },
  {
    title: 'RESTful API Design Patterns',
    channelName: 'API Masters',
    thumbnailUrl: 'https://picsum.photos/seed/video6/640/360',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    duration: '16:55',
    publishedDate: new Date('2024-02-20'),
    description: 'Learn the best practices and design patterns for building RESTful APIs.',
    viewCount: 25480,
    likeCount: 1950,
  },
  {
    title: 'State Management in Flutter',
    channelName: 'Flutter Academy',
    thumbnailUrl: 'https://picsum.photos/seed/video7/640/360',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
    duration: '20:30',
    publishedDate: new Date('2024-02-25'),
    description: 'Deep dive into different state management solutions in Flutter.',
    viewCount: 38920,
    likeCount: 3180,
  },
  {
    title: 'JWT Authentication Explained',
    channelName: 'Security First',
    thumbnailUrl: 'https://picsum.photos/seed/video8/640/360',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    duration: '14:25',
    publishedDate: new Date('2024-03-01'),
    description: 'Everything you need to know about JSON Web Token authentication.',
    viewCount: 29650,
    likeCount: 2340,
  },
  {
    title: 'Docker for Beginners',
    channelName: 'DevOps Guide',
    thumbnailUrl: 'https://picsum.photos/seed/video9/640/360',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
    duration: '25:40',
    publishedDate: new Date('2024-03-05'),
    description: 'Get started with Docker and containerization in this beginner-friendly tutorial.',
    viewCount: 45280,
    likeCount: 3890,
  },
  {
    title: 'TypeScript Advanced Features',
    channelName: 'TypeScript Pro',
    thumbnailUrl: 'https://picsum.photos/seed/video10/640/360',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    duration: '19:15',
    publishedDate: new Date('2024-03-10'),
    description: 'Explore advanced TypeScript features and patterns for better code.',
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
