import User from './User';
import FCMToken from './FCMToken';
import Video from './Video';
import Notification from './Notification';
import VideoProgress from './VideoProgress';

// Define associations
User.hasMany(FCMToken, {
  foreignKey: 'user_id',
  as: 'fcmTokens',
});

FCMToken.belongsTo(User, {
  foreignKey: 'user_id',
  as: 'user',
});

User.hasMany(Notification, {
  foreignKey: 'userId',
  as: 'notifications',
});

Notification.belongsTo(User, {
  foreignKey: 'userId',
  as: 'user',
});

User.hasMany(VideoProgress, {
  foreignKey: 'userId',
  as: 'videoProgress',
});

VideoProgress.belongsTo(User, {
  foreignKey: 'userId',
  as: 'user',
});

Video.hasMany(VideoProgress, {
  foreignKey: 'videoId',
  as: 'progress',
});

VideoProgress.belongsTo(Video, {
  foreignKey: 'videoId',
  as: 'video',
});

export { User, FCMToken, Video, Notification, VideoProgress };
