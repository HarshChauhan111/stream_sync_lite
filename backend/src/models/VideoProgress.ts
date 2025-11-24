import { DataTypes, Model, Optional } from 'sequelize';
import sequelize from '../config/database';

interface VideoProgressAttributes {
  id: number;
  userId: number;
  videoId: number;
  lastPlayedPosition: number;
  isFavorite: boolean;
  createdAt?: Date;
  updatedAt?: Date;
}

interface VideoProgressCreationAttributes extends Optional<VideoProgressAttributes, 'id' | 'lastPlayedPosition' | 'isFavorite' | 'createdAt' | 'updatedAt'> {}

class VideoProgress extends Model<VideoProgressAttributes, VideoProgressCreationAttributes> implements VideoProgressAttributes {
  public id!: number;
  public userId!: number;
  public videoId!: number;
  public lastPlayedPosition!: number;
  public isFavorite!: boolean;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;
}

VideoProgress.init(
  {
    id: {
      type: DataTypes.INTEGER.UNSIGNED,
      autoIncrement: true,
      primaryKey: true,
    },
    userId: {
      type: DataTypes.INTEGER.UNSIGNED,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id',
      },
      onDelete: 'CASCADE',
    },
    videoId: {
      type: DataTypes.INTEGER.UNSIGNED,
      allowNull: false,
      references: {
        model: 'videos',
        key: 'id',
      },
      onDelete: 'CASCADE',
    },
    lastPlayedPosition: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
      comment: 'Position in seconds',
    },
    isFavorite: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
  },
  {
    sequelize,
    tableName: 'video_progress',
    timestamps: true,
    indexes: [
      {
        unique: true,
        fields: ['userId', 'videoId'],
      },
    ],
  }
);

export default VideoProgress;
