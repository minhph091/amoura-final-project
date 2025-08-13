const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

async function convertToIco() {
  try {
    const inputPath = path.join(__dirname, 'mobile_app', 'assets', 'logos', 'light_amoura.png');
    
    // Convert for landing page
    await sharp(inputPath)
      .resize(32, 32)
      .png()
      .toFile(path.join(__dirname, 'landing_page', 'public', 'favicon-32x32.png'));
    
    await sharp(inputPath)
      .resize(16, 16)
      .png()
      .toFile(path.join(__dirname, 'landing_page', 'public', 'favicon-16x16.png'));
    
    // Convert for admin dashboard
    await sharp(inputPath)
      .resize(32, 32)
      .png()
      .toFile(path.join(__dirname, 'admin_dashboard', 'public', 'favicon-32x32.png'));
    
    await sharp(inputPath)
      .resize(16, 16)
      .png()
      .toFile(path.join(__dirname, 'admin_dashboard', 'public', 'favicon-16x16.png'));
    
    console.log('Favicon files created successfully!');
  } catch (error) {
    console.error('Error converting favicon:', error);
  }
}

convertToIco();
