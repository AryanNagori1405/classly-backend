# classly-backend

Node.js + Express.js backend for the **Classly** lecture sharing platform.

---

## Tech Stack

| Layer        | Technology                  |
|--------------|-----------------------------|
| Runtime      | Node.js                     |
| Framework    | Express.js                  |
| Database     | PostgreSQL (via `pg`)       |
| Auth         | JSON Web Tokens (`jsonwebtoken`) |
| Passwords    | bcrypt (`bcryptjs`)         |
| Config       | `dotenv`                    |

---

## Project Structure

```
classly-backend/
├── src/
│   ├── config/
│   │   └── database.js          # PostgreSQL connection pool
│   ├── controllers/
│   │   └── userController.js    # Register & login logic
│   ├── middleware/
│   │   ├── auth.js              # JWT authentication middleware
│   │   ├── authMiddleware.js    # Role-based access helpers
│   │   └── errorHandler.js     # Global error handler
│   ├── models/
│   │   └── User.js              # User schema reference
│   ├── routes/
│   │   └── auth.js              # Auth routes (/register, /login)
│   └── utils/
│       ├── jwt.js               # JWT helpers
│       └── validators.js        # Input validation utilities
├── .env.example                 # Environment variable template
├── .gitignore
├── database-setup.sql           # SQL to initialise database tables
├── package.json
└── README.md
```

---

## Getting Started

### Prerequisites

- Node.js ≥ 14
- PostgreSQL ≥ 12

### 1. Clone the repository

```bash
git clone https://github.com/AryanNagori1405/classly-backend.git
cd classly-backend
```

### 2. Install dependencies

```bash
npm install
```

### 3. Configure environment variables

```bash
cp .env.example .env
```

Edit `.env` and fill in your database credentials and a strong `JWT_SECRET`.

### 4. Initialise the database

Connect to PostgreSQL and run:

```bash
psql -U postgres -d classly_db -f database-setup.sql
```

Or paste the contents of `database-setup.sql` directly into `psql` / pgAdmin.

### 5. Start the server

```bash
# Production
npm start

# Development (auto-restart with nodemon)
npm run dev
```

The API will be available at `http://localhost:5000`.

---

## API Reference

### Health check

```
GET /
```

**Response**
```json
{ "message": "Welcome to Classly Backend API" }
```

---

### Auth

#### Register

```
POST /api/auth/register
Content-Type: application/json

{
  "username": "alice",
  "password": "Secret@123"
}
```

**Success (201)**
```json
{
  "message": "User registered successfully",
  "user": { "id": 1, "username": "alice" }
}
```

#### Login

```
POST /api/auth/login
Content-Type: application/json

{
  "username": "alice",
  "password": "Secret@123"
}
```

**Success (200)**
```json
{
  "message": "Login successful",
  "token": "<jwt>"
}
```

---

### Protecting routes with JWT

Include the token returned from `/login` in the `Authorization` header:

```
Authorization: Bearer <token>
```

In your route file:

```js
const auth = require('../middleware/auth');

router.get('/protected', auth, (req, res) => {
    res.json({ message: 'Authenticated!', user: req.user });
});
```

---

## Environment Variables

| Variable      | Description                           | Example             |
|---------------|---------------------------------------|---------------------|
| `DB_USER`     | PostgreSQL username                   | `postgres`          |
| `DB_HOST`     | PostgreSQL host                       | `localhost`         |
| `DB_NAME`     | PostgreSQL database name              | `classly_db`        |
| `DB_PASSWORD` | PostgreSQL password                   | `secret`            |
| `DB_PORT`     | PostgreSQL port                       | `5432`              |
| `JWT_SECRET`  | Secret used to sign JWT tokens        | `changeme`          |
| `PORT`        | Port the Express server listens on    | `5000`              |
| `NODE_ENV`    | Environment mode                      | `development`       |

---

## License

ISC
