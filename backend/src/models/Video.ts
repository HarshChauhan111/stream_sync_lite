import { DataTypes, Model, Optional } from 'sequelize';
import sequelize from '../config/database';

interface VideoAttributes {
  id: number;
  title: string;
  channelName: string;
  thumbnailUrl: string;
  videoUrl: string;
  duration: string;
  publishedDate: Date;
  description?: string;
  viewCount: number;
  likeCount: number;
  createdAt?: Date;
  updatedAt?: Date;
}

interface VideoCreationAttributes extends Optional<VideoAttributes, 'id' | 'viewCount' | 'likeCount' | 'createdAt' | 'updatedAt'> {}

class Video extends Model<VideoAttributes, VideoCreationAttributes> implements VideoAttributes {
  public id!: number;
  public title!: string;
  public channelName!: string;
  public thumbnailUrl!: string;
  public videoUrl!: string;
  public duration!: string;
  public publishedDate!: Date;
  public description?: string;
  public viewCount!: number;
  public likeCount!: number;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;
}

Video.init(
  {
    id: {
      type: DataTypes.INTEGER.UNSIGNED,
      autoIncrement: true,
      primaryKey: true,
    },
    title: {
      type: DataTypes.STRING(500),
      allowNull: false,
    },
    channelName: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    thumbnailUrl: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    videoUrl: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    duration: {
      type: DataTypes.STRING(20),
      allowNull: false,
      defaultValue: '0:00',
    },
    publishedDate: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    viewCount: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
    },
    likeCount: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
    },
  },
  {
    sequelize,
    tableName: 'videos',
    timestamps: true,
  }
);

export default Video;
