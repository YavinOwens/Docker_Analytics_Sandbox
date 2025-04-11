import React, { useState, useEffect } from 'react';
import { MinioClient } from '../services/minioClient';

const ReposComponent = () => {
  const [files, setFiles] = useState([]);
  const [currentPath, setCurrentPath] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  // Function to fetch files
  const fetchFiles = async () => {
    try {
      setLoading(true);
      setError(null);
      const fileList = await MinioClient.listObjects(currentPath);
      setFiles(fileList);
    } catch (err) {
      setError('Failed to fetch files');
      console.error('Error fetching files:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchFiles();
  }, [currentPath]); // eslint-disable-line react-hooks/exhaustive-deps

  const handleFileClick = (file) => {
    if (file.isDirectory) {
      setCurrentPath(file.path);
    } else {
      // Handle file selection
      console.log('Selected file:', file);
    }
  };

  const handleUpload = async (event) => {
    const file = event.target.files[0];
    if (file) {
      try {
        setLoading(true);
        await MinioClient.uploadFile(file, currentPath);
        fetchFiles();
      } catch (err) {
        setError('Failed to upload file');
        console.error('Error uploading file:', err);
      } finally {
        setLoading(false);
      }
    }
  };

  return (
    <div className="p-4">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-xl font-semibold">Repositories</h2>
        <div className="flex space-x-2">
          <input
            type="file"
            onChange={handleUpload}
            className="hidden"
            id="file-upload"
          />
          <button
            onClick={() => document.getElementById('file-upload').click()}
            className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
          >
            Upload File
          </button>
        </div>
      </div>

      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
      )}

      {loading ? (
        <div className="flex justify-center items-center h-64">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>
        </div>
      ) : (
        <div className="bg-white rounded-lg shadow">
          <div className="p-4 border-b">
            <nav className="flex" aria-label="Breadcrumb">
              <ol className="flex items-center space-x-2">
                <li>
                  <button
                    onClick={() => setCurrentPath('')}
                    className="text-blue-500 hover:text-blue-700"
                  >
                    Root
                  </button>
                </li>
                {currentPath.split('/').map((part, index) => (
                  <li key={index} className="flex items-center">
                    <span className="mx-2 text-gray-500">/</span>
                    <button
                      onClick={() =>
                        setCurrentPath(
                          currentPath
                            .split('/')
                            .slice(0, index + 1)
                            .join('/')
                        )
                      }
                      className="text-blue-500 hover:text-blue-700"
                    >
                      {part}
                    </button>
                  </li>
                ))}
              </ol>
            </nav>
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Name
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Size
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Last Modified
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {files.map((file, index) => (
                  <tr
                    key={index}
                    onClick={() => handleFileClick(file)}
                    className="hover:bg-gray-50 cursor-pointer"
                  >
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="flex-shrink-0 h-10 w-10">
                          {file.isDirectory ? (
                            <svg
                              className="h-10 w-10 text-gray-400"
                              fill="none"
                              stroke="currentColor"
                              viewBox="0 0 24 24"
                            >
                              <path
                                strokeLinecap="round"
                                strokeLinejoin="round"
                                strokeWidth="2"
                                d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"
                              />
                            </svg>
                          ) : (
                            <svg
                              className="h-10 w-10 text-gray-400"
                              fill="none"
                              stroke="currentColor"
                              viewBox="0 0 24 24"
                            >
                              <path
                                strokeLinecap="round"
                                strokeLinejoin="round"
                                strokeWidth="2"
                                d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                              />
                            </svg>
                          )}
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-gray-900">
                            {file.name}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {file.size}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {file.lastModified}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
};

export default ReposComponent; 