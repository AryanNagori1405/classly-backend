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
   * Auto-incremented primary key
   * @type {number}
   */
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
    allowNull: false,
  },

  /**
   * Registration number – used as the login identifier
   * @type {string}
   */
  reg_no: {
    type: DataTypes.STRING(100),
    unique: true,
    allowNull: false,
  },

  /**
   * Full name of the user
   * @type {string}
   */
  name: {
    type: DataTypes.STRING(255),
    allowNull: false,
  },

  /**
   * Email address of the user
   * @type {string}
   */
  email: {
    type: DataTypes.STRING(255),
    unique: true,
    allowNull: false,
  },

  /**
   * Phone number of the user
   * @type {string}
   */
  phone: {
    type: DataTypes.STRING(20),
    allowNull: false,
  },

  /**
   * Role of the user
   * @type {string}
   */
  role: {
    type: DataTypes.ENUM('student', 'teacher', 'admin'),
    allowNull: false,
    defaultValue: 'student',
  },

  /**
   * Bcrypt-hashed password
   * @type {string}
   */
  password_hash: {
    type: DataTypes.STRING(255),
    allowNull: true,
  },

  /**
   * URL or path to the user's profile image
   * @type {string}
   */
  profile_image: {
    type: DataTypes.TEXT,
    allowNull: true,
  },

  /**
   * Short biography
   * @type {string}
   */
  bio: {
    type: DataTypes.TEXT,
    allowNull: true,
  },

  /**
   * Whether the user's account has been verified
   * @type {boolean}
   */
  is_verified: {
    type: DataTypes.BOOLEAN,
    allowNull: false,
    defaultValue: false,
  },

  /**
   * Whether the user's account is active
   * @type {boolean}
   */
  is_active: {
    type: DataTypes.BOOLEAN,
    allowNull: false,
    defaultValue: true,
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