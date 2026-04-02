// Updated src/index.js file with complete enrollment routes integration

const express = require('express');
const enrollmentRoutes = require('./routes/enrollmentRoutes');

const app = express();
app.use(express.json());

// Other route integrations...

app.use('/api/enrollments', enrollmentRoutes);

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});