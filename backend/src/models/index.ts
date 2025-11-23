import User from './User';
import FCMToken from './FCMToken';

// Define associations
User.hasMany(FCMToken, {
  foreignKey: 'user_id',
  as: 'fcmTokens',
});

FCMToken.belongsTo(User, {
  foreignKey: 'user_id',
  as: 'user',
});

export { User, FCMToken };
