require('dotenv').config();
const express = require('express');
const authRoutes = require('./routes/authRoutes');
const astrologyRoutes = require('./routes/astrologyRoutes');

const app = express();
app.use(express.json());

const mongoose = require('mongoose');

mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('Connected to MongoDB'))
  .catch((err) => console.error('Failed to connect to MongoDB:', err));

app.use('/api/auth', authRoutes);
app.use('/api/astrology', astrologyRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
