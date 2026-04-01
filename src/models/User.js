const { Sequelize, Model, DataTypes } = require('sequelize');

// NOTE: This file is a reference model using Sequelize ORM.
// The rest of the application uses raw `pg` queries via src/config/database.js.
// If you migrate to Sequelize, move the connection below into a shared
// src/config/sequelize.js file and import it here instead.
const sequelize = new Sequelize(
    process.env.DB_NAME,
    process.env.DB_USER,
    process.env.DB_PASSWORD,
    {
        host: process.env.DB_HOST || 'localhost',
        port: process.env.DB_PORT || 5432,
        dialect: 'postgres',
        logging: false,
    }
);

/**
 * User Model Schema for PostgreSQL
 * Defines the structure of the User table in the database
 */
class User extends Model {}

User.init({
  /**
   * Unique identifier for the user
   * @type {string}
   */
  uid: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
    allowNull: false,
  },

  /**
   * Registration ID assigned to the user
   * @type {string}
   */
  regId: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: false,
  },

  /**
   * Name of the user
   * @type {string}
   */
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },

  /**
   * Email address of the user
   * @type {string}
   */
  email: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: false,
  },

  /**
   * Role of the user (e.g. teacher or student)
   * @type {string}
   */
  role: {
    type: DataTypes.ENUM('teacher', 'student'),
    allowNull: false,
  },

  /**
   * Timestamp of when the user was created
   * @type {Date}
   */
  createdAt: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },

  /**
   * Timestamp of when the user information was last updated
   * @type {Date}
   */
  updatedAt: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
}, {
  sequelize, // passing the `sequelize` instance is required
  modelName: 'User',
  timestamps: true, // enables createdAt and updatedAt fields
});

module.exports = User;