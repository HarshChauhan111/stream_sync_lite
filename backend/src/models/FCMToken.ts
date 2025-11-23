import { DataTypes, Model, Optional } from 'sequelize';
import sequelize from '../config/database';

export enum Platform {
  ANDROID = 'android',
  IOS = 'ios',
  WEB = 'web',
}

interface FCMTokenAttributes {
  id: number;
  user_id: number;
  token: string;
  platform: Platform;
  created_at: Date;
  updated_at: Date;
}

interface FCMTokenCreationAttributes extends Optional<FCMTokenAttributes, 'id' | 'created_at' | 'updated_at'> {}

class FCMToken extends Model<FCMTokenAttributes, FCMTokenCreationAttributes> implements FCMTokenAttributes {
  public id!: number;
  public user_id!: number;
  public token!: string;
  public platform!: Platform;
  public created_at!: Date;
  public updated_at!: Date;
}

FCMToken.init(
  {
    id: {
      type: DataTypes.INTEGER.UNSIGNED,
      autoIncrement: true,
      primaryKey: true,
    },
    user_id: {
      type: DataTypes.INTEGER.UNSIGNED,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id',
      },
      onDelete: 'CASCADE',
      onUpdate: 'CASCADE',
    },
    token: {
      type: DataTypes.STRING(500),
      allowNull: false,
    },
    platform: {
      type: DataTypes.ENUM(Platform.ANDROID, Platform.IOS, Platform.WEB),
      allowNull: false,
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
    updated_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    sequelize,
    tableName: 'fcm_tokens',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    indexes: [
      {
        unique: true,
        fields: ['user_id', 'token'],
        name: 'unique_user_token',
      },
      {
        fields: ['user_id'],
        name: 'idx_user_id',
      },
    ],
  }
);

export default FCMToken;
