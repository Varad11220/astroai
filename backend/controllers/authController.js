const Otp = require('../models/OtpModel');
const generateOtp = require('../utils/generateOtp');
const sendEmail = require('../utils/sendEmail');

exports.requestOtp = async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ error: 'Email is required' });

  const otp = generateOtp();

  try {
    await Otp.create({ email, otp });

    try {
      await sendEmail(email, otp);
      res.status(200).json({ message: 'OTP sent successfully' });
    } catch (emailError) {
      console.error('Failed to send email:', emailError);
      // Clean up the OTP record since we couldn't send the email
      await Otp.deleteOne({ email, otp });
      res.status(500).json({ error: 'Failed to send OTP email. Please try again.' });
    }
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ error: 'Failed to generate OTP' });
  }
};

exports.verifyOtp = async (req, res) => {
  const { email, otp } = req.body;
  if (!email || !otp) return res.status(400).json({ error: 'Email and OTP are required' });

  try {
    const existingOtp = await Otp.findOne({ email, otp });

    if (!existingOtp) {
      return res.status(400).json({ error: 'Invalid or expired OTP' });
    }

    // OTP is correct, delete it from the database
    await Otp.deleteOne({ email });

    res.status(200).json({ message: 'OTP verified successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to verify OTP' });
  }
};
