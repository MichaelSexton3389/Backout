const { Storage } = require('@google-cloud/storage');
const { v4: uuidv4 } = require('uuid');
const path = require('path');

// Initialize GCP Storage
const storage = new Storage({
  keyFilename: path.join(__dirname, '../config/service-account.json'), // Path to your GCP service account key
  projectId: 'your-project-id', // Replace with your GCP project ID
});

const bucketName = 'your-bucket-name'; // Replace with your bucket name
const bucket = storage.bucket(bucketName);

async function uploadImage(base64Image) {
  const buffer = Buffer.from(base64Image, 'base64');
  const fileName = `${uuidv4()}.jpg`; // Generate a unique file name
  const file = bucket.file(fileName);

  await file.save(buffer, {
    metadata: {
      contentType: 'image/jpeg',
    },
  });

  // Make the file publicly accessible
  await file.makePublic();

  // Return the public URL
  return `https://storage.googleapis.com/${bucketName}/${fileName}`;
}

module.exports = { uploadImage };