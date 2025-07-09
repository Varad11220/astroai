const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

async function sendEmail(email, otp) {
  const mailOptions = {
    from: `"PAC App" <${process.env.SMTP_USER}>`,
    to: email,
    subject: 'Your Verification Code for PAC App',
    text: `Hello,

Thank you for registering with PAC App. 

Your verification code is: ${otp}

This code will expire in 5 minutes.

If you did not request this code, please ignore this email.

Best regards,
The PAC App Team
`,
    html: `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 5px;">
      <div style="text-align: center; margin-bottom: 20px;">
        <h2 style="color: #4285f4;">PAC App Verification</h2>
      </div>
      <p>Hello,</p>
      <p>Thank you for registering with PAC App.</p>
      <p>Your verification code is:</p>
      <div style="background-color: #f8f9fa; padding: 12px; text-align: center; font-size: 24px; font-weight: bold; letter-spacing: 5px; margin: 20px 0; border-radius: 4px;">
        ${otp}
      </div>
      <p>This code will expire in <strong>5 minutes</strong>.</p>
      <p>If you did not request this code, please ignore this email.</p>
      <p>Best regards,<br>The PAC App Team</p>
    </div>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log('Email sent successfully');
  } catch (error) {
    console.error('Error sending email:', error);
    throw error; // Rethrow to let the calling function know about the error
  }
}

module.exports = sendEmail;
