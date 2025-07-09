# Jyotish API Server

This is a Node.js Express server that provides Vedic astrological insights (Jyotish) using Swiss Ephemeris and Google's Gemini API.

## Setup Instructions

1. Install dependencies:
   ```
   npm install
   ```

2. Set up environment variables:
   Create a `.env` file with the following variables:
   ```
   PORT=3000
   MONGO_URI=your_mongodb_connection_string
   GEMINI_API_KEY=your_gemini_api_key
   ```

3. Download Swiss Ephemeris files:
   - Go to https://www.astro.com/ftp/swisseph/ephe/
   - Download the required ephemeris files and place them in the `ephe` directory
   - At minimum, you'll need: sepl_18.se1, semo_18.se1, seas_18.se1

4. Start the server:
   ```
   npm start
   ```
   Or for development:
   ```
   npm run dev
   ```

## API Endpoints

### Get Jyotish Insight
```
POST /api/astrology/insight
```

**Request Body:**
```json
{
  "query": "What color should I wear today for good fortune?",
  "birthDate": "1990-01-01",  // Optional
  "birthTime": "12:00",       // Optional
  "birthPlace": "New Delhi",  // Optional
  "userId": "user123"         // Optional
}
```

**Response:**
```json
{
  "success": true,
  "response": "The divine energies suggest wearing yellow today..."
}
```

## Features

- Calculates planetary positions according to Vedic astrology principles
- Determines Rashi (zodiac sign), Nakshatra (lunar mansion), and Pada (quarter)
- Provides mystical guidance based on Hindu astrological principles
- Uses Google's Gemini 2.0 Flash AI model for generating responses
- Includes references to Hindu mythology and deities when appropriate