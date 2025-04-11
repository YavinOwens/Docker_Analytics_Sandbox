// Browser-compatible MinIO client using fetch API
const MINIO_ENDPOINT = process.env.REACT_APP_MINIO_ENDPOINT || 'localhost';
const MINIO_PORT = process.env.REACT_APP_MINIO_PORT || '9000';
const MINIO_USE_SSL = process.env.REACT_APP_MINIO_USE_SSL === 'true';

// For debugging
console.log('MinIO Configuration:', {
  endpoint: MINIO_ENDPOINT,
  port: MINIO_PORT,
  useSSL: MINIO_USE_SSL
});

// These are kept for future implementation with real MinIO integration
// const MINIO_ACCESS_KEY = process.env.REACT_APP_MINIO_ACCESS_KEY || 'minioadmin';
// const MINIO_SECRET_KEY = process.env.REACT_APP_MINIO_SECRET_KEY || 'minioadmin';
// const BUCKET_NAME = process.env.REACT_APP_MINIO_BUCKET || 'repos';

// API Base URL (kept for future real implementation)
// const protocol = MINIO_USE_SSL ? 'https' : 'http';
// const apiBaseUrl = `${protocol}://${MINIO_ENDPOINT}:${MINIO_PORT}`;

// Format bytes to human-readable format
const formatBytes = (bytes, decimals = 2) => {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const dm = decimals < 0 ? 0 : decimals;
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
};

export const MinioClient = {
  // List objects in a bucket with a prefix
  async listObjects(prefix = '') {
    try {
      // For demonstration purposes, we'll use a mock implementation
      // In a real implementation, you would use MinIO's REST API
      
      // Simulate API request
      await new Promise(resolve => setTimeout(resolve, 500));
      
      // Mock response with sample data
      const mockFiles = [
        {
          name: 'test.txt',
          path: `${prefix}test.txt`,
          isDirectory: false,
          size: formatBytes(18),
          lastModified: new Date().toLocaleString(),
        },
        {
          name: 'sample_data',
          path: `${prefix}sample_data/`,
          isDirectory: true,
          size: formatBytes(0),
          lastModified: new Date().toLocaleString(),
        },
        {
          name: 'example.py',
          path: `${prefix}example.py`,
          isDirectory: false,
          size: formatBytes(1024),
          lastModified: new Date().toLocaleString(),
        }
      ];
      
      // If we're in a subfolder, add an option to go back
      if (prefix) {
        mockFiles.unshift({
          name: '..',
          path: prefix.split('/').slice(0, -2).join('/') + '/',
          isDirectory: true,
          size: formatBytes(0),
          lastModified: '',
        });
      }
      
      return mockFiles;
    } catch (error) {
      console.error('Error listing objects:', error);
      throw error;
    }
  },

  // Upload a file to MinIO
  async uploadFile(file, path) {
    try {
      // Simulate upload
      await new Promise(resolve => setTimeout(resolve, 1000));
      console.log(`File uploaded: ${file.name} to path: ${path}`);
      return true;
    } catch (error) {
      console.error('Error uploading file:', error);
      throw error;
    }
  },

  // Download a file from MinIO
  async downloadFile(objectName) {
    try {
      // Simulate download
      await new Promise(resolve => setTimeout(resolve, 1000));
      console.log(`File downloaded: ${objectName}`);
      return {};
    } catch (error) {
      console.error('Error downloading file:', error);
      throw error;
    }
  },

  // Delete a file from MinIO
  async deleteFile(objectName) {
    try {
      // Simulate deletion
      await new Promise(resolve => setTimeout(resolve, 500));
      console.log(`File deleted: ${objectName}`);
      return true;
    } catch (error) {
      console.error('Error deleting file:', error);
      throw error;
    }
  },
}; 