const express = require('express');
const router = express.Router();
const astrologyController = require('../controllers/astrologyController');

// Route for getting astrological insights
router.post('/insight', astrologyController.getAstrologicalInsight);

module.exports = router; 