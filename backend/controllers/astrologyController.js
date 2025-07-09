const axios = require('axios');
const swisseph = require('swisseph');

// Initialize Swiss Ephemeris
swisseph.swe_set_ephe_path(`${__dirname}/../ephe`); // Path to ephemeris files

// Gemini API configuration
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent';


/**
 * Get astrological insight based on user query
 */
exports.getAstrologicalInsight = async (req, res) => {
  try {
    const { query, birthDate, birthTime, birthPlace, userId } = req.body;

    if (!query) {
      return res.status(400).json({ message: 'Query is required' });
    }

    // Get astrological data if birth details are provided
    let astroData = {};
    if (birthDate && birthTime && birthPlace) {
      astroData = await calculateAstrologicalData(birthDate, birthTime, birthPlace);
    }

    // Generate response using Gemini API
    const response = await generateGeminiResponse(query, astroData);

    return res.status(200).json({
      success: true,
      response: response
    });

  } catch (error) {
    console.error('Error in getAstrologicalInsight:', error);
    return res.status(500).json({
      success: false,
      message: 'An error occurred while processing your request',
      error: error.message
    });
  }
};

/**
 * Calculate astrological data using Swisseph
 */
async function calculateAstrologicalData(birthDate, birthTime, birthPlace) {
  try {
    // Parse birth date and time
    const [year, month, day] = birthDate.split('-').map(num => parseInt(num));
    const [hour, minute] = birthTime.split(':').map(num => parseInt(num));
    
    // Calculate Julian day
    const julianDay = swisseph.swe_julday(
      year,
      month,
      day,
      hour + minute / 60,
      swisseph.SE_GREG_CAL
    );

    // Define planets to calculate (include Hindu/Vedic names)
    const planets = [
      { id: swisseph.SE_SUN, name: 'Sun', hinduName: 'Surya' },
      { id: swisseph.SE_MOON, name: 'Moon', hinduName: 'Chandra' },
      { id: swisseph.SE_MERCURY, name: 'Mercury', hinduName: 'Budha' },
      { id: swisseph.SE_VENUS, name: 'Venus', hinduName: 'Shukra' },
      { id: swisseph.SE_MARS, name: 'Mars', hinduName: 'Mangala' },
      { id: swisseph.SE_JUPITER, name: 'Jupiter', hinduName: 'Guru' },
      { id: swisseph.SE_SATURN, name: 'Saturn', hinduName: 'Shani' },
      { id: swisseph.SE_MEAN_NODE, name: 'Rahu', hinduName: 'Rahu' },
      { id: swisseph.SE_MEAN_NODE, name: 'Ketu', hinduName: 'Ketu', ketu: true }
    ];

    // Calculate positions
    const planetPositions = planets.map(planet => {
      let result = swisseph.swe_calc_ut(julianDay, planet.id, swisseph.SEFLG_SPEED);
      
      // For Ketu, add 180 degrees to Rahu
      if (planet.ketu) {
        result.longitude = (result.longitude + 180) % 360;
      }
      
      const nakshatra = getNakshatra(result.longitude);
      const rashiIndex = Math.floor(result.longitude / 30) % 12;
      
      return {
        name: planet.name,
        hinduName: planet.hinduName,
        longitude: result.longitude,
        rashiIndex: rashiIndex,
        rashi: getHinduZodiacSign(rashiIndex),
        nakshatra: nakshatra.name,
        nakshatraPada: nakshatra.pada
      };
    });

    // Calculate ascendant (Lagna)
    const houses = swisseph.swe_houses(
      julianDay,
      0, // Latitude (placeholder - should be dynamically calculated based on birthPlace)
      0, // Longitude (placeholder - should be dynamically calculated based on birthPlace)
      'P' // Placidus house system
    );

    const ascendantNakshatra = getNakshatra(houses.ascendant);
    const ascendantRashiIndex = Math.floor(houses.ascendant / 30) % 12;

    return {
      birthChart: {
        planets: planetPositions,
        lagna: {
          longitude: houses.ascendant,
          rashi: getHinduZodiacSign(ascendantRashiIndex),
          nakshatra: ascendantNakshatra.name,
          nakshatraPada: ascendantNakshatra.pada
        },
        houses: houses.cusps
      }
    };
  } catch (error) {
    console.error('Error calculating astrological data:', error);
    return { error: 'Could not calculate astrological data' };
  }
}

/**
 * Get Hindu/Vedic zodiac sign
 */
function getHinduZodiacSign(rashiIndex) {
  const signs = [
    'Mesha', 'Vrishabha', 'Mithuna', 'Karka',
    'Simha', 'Kanya', 'Tula', 'Vrishchika',
    'Dhanu', 'Makara', 'Kumbha', 'Meena'
  ];
  
  return signs[rashiIndex];
}

/**
 * Get Nakshatra (lunar mansion) and pada based on longitude
 */
function getNakshatra(longitude) {
  const nakshatras = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra', 
    'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni',
    'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha',
    'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha',
    'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
  ];
  
  // Each nakshatra spans 13°20' (or 13.33333 degrees)
  const nakshatraLength = 13.33333;
  const nakshatraIndex = Math.floor(longitude / nakshatraLength) % 27;
  
  // Calculate pada (quarter) within nakshatra
  const positionInNakshatra = longitude % nakshatraLength;
  const padaLength = nakshatraLength / 4;
  const pada = Math.floor(positionInNakshatra / padaLength) + 1;
  
  return {
    name: nakshatras[nakshatraIndex],
    pada: pada
  };
}


async function generateGeminiResponse(query, astroData) {
  try {
    // Create prompt with user query and astrological data but without revealing calculation methods
    let prompt = `You are an expert in Hindu astrology. A user has asked: "${query}"\n\n`;
    
    if (astroData.birthChart) {
      prompt += "Use the following astrological information to make your prediction, but DO NOT mention that you have this information:\n\n";
      
      // Add planet positions
      prompt += "Planetary positions:\n";
      astroData.birthChart.planets.forEach(planet => {
        prompt += `- ${planet.hinduName} (${planet.name}): ${planet.rashi} Rashi, ${planet.nakshatra} Nakshatra ${planet.nakshatraPada}th Pada\n`;
      });
      
      // Add Lagna (Ascendant)
      prompt += `\nLagna: ${astroData.birthChart.lagna.rashi} Rashi, ${astroData.birthChart.lagna.nakshatra} Nakshatra ${astroData.birthChart.lagna.nakshatraPada}th Pada\n\n`;
    }
    
    prompt += "Important instructions:\n";
    prompt += "1. Provide direct, practical advice that answers the user's question clearly.\n";
    prompt += "2. NEVER mention the birth details or that you are using astrological calculations.\n";
    prompt += "3. Keep responses modern, concise, and to the point - focus exactly on what was asked.\n";
    prompt += "4. For questions about colors, activities, or life decisions, provide specific advice without mystical explanations.\n";
    prompt += "5. Use a confident tone but avoid excessive mystical language.\n";
    prompt += "6. DO NOT add references to mythology, deities, or ancient wisdom unless specifically asked.\n";
    prompt += "7. If the question is about prediction or guidance, give a straightforward answer without embellishment.\n";
    prompt += "8. Keep responses under 3-4 sentences when possible.\n\n";
    
    prompt += "Please provide your insight now:";

    // Make request to Gemini API
    const response = await axios.post(
      `${GEMINI_API_URL}?key=${GEMINI_API_KEY}`,
      {
        contents: [
          {
            parts: [
              {
                text: prompt
              }
            ]
          }
        ],
        generationConfig: {
          temperature: 0.7,
          maxOutputTokens: 1024
        }
      }
    );

    // Extract and return the generated text
    return response.data.candidates[0].content.parts[0].text;
  } catch (error) {
    console.error('Error generating Gemini response:', error);
    return "Unable to process your request at this moment. Please try again later.";
  }
} 