import React, { useState, useEffect } from 'react';
import DatabricksUI from './components/DatabricksUI';
import ReposComponent from './components/ReposComponent';
import DataComponent from './components/DataComponent';
import './App.css';

function App() {
  const [activeTab, setActiveTab] = useState('notebook');
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [activeSection, setActiveSection] = useState('workspace');
  const [servicesStatus, setServicesStatus] = useState({
    integration: { status: 'unknown', message: 'Checking...' },
    oracle: { status: 'unknown', message: 'Checking...' },
    minio: { status: 'unknown', message: 'Checking...' }
  });

  // Check integration service status
  useEffect(() => {
    const checkServices = async () => {
      // Check integration service
      try {
        const response = await fetch(process.env.REACT_APP_API_URL || 'http://localhost:8000');
        if (response.ok) {
          setServicesStatus(prev => ({
            ...prev,
            integration: { status: 'online', message: 'Integration service online' }
          }));
          
          // Now check Oracle via the integration service
          try {
            const oracleResponse = await fetch(`${process.env.REACT_APP_API_URL || 'http://localhost:8000'}/api/oracle/tables`);
            if (oracleResponse.ok) {
              setServicesStatus(prev => ({
                ...prev,
                oracle: { status: 'online', message: 'Oracle service available' }
              }));
            } else {
              setServicesStatus(prev => ({
                ...prev,
                oracle: { status: 'mock', message: 'Using Oracle mock data' }
              }));
            }
          } catch (e) {
            setServicesStatus(prev => ({
              ...prev,
              oracle: { status: 'mock', message: 'Using Oracle mock data' }
            }));
          }
        }
      } catch (error) {
        setServicesStatus(prev => ({
          ...prev,
          integration: { status: 'offline', message: 'Integration service offline' }
        }));
      }
      
      // Set MinIO status to mock as we're using mock data
      setServicesStatus(prev => ({
        ...prev,
        minio: { status: 'mock', message: 'Using MinIO mock data' }
      }));
    };
    
    checkServices();
  }, []);

  const handleTabClick = (tab) => {
    setActiveTab(tab);
  };

  const handleSidebarToggle = () => {
    setSidebarOpen(!sidebarOpen);
  };

  const handleSidebarItemClick = (section) => {
    setActiveSection(section);
  };

  // Render the appropriate component based on the active section
  const renderContent = () => {
    if (activeSection === 'repos') {
      return <ReposComponent />;
    } else if (activeTab === 'notebook') {
      return (
        <div className="p-4">
          <div className="mb-4">
            <select className="px-4 py-2 border rounded">
              <option>Python</option>
              <option>SQL</option>
              <option>R</option>
              <option>Scala</option>
            </select>
            <button className="ml-2 px-4 py-2 bg-blue-500 text-white rounded">Run</button>
          </div>
          <div className="border rounded p-4 bg-white">
            <pre className="font-mono text-sm">
              {`# Example Python cell
import pyspark.sql.functions as F

# Create a sample DataFrame
df = spark.createDataFrame([
  (1, 'John', 35),
  (2, 'Alice', 28),
  (3, 'Bob', 42)
], ['id', 'name', 'age'])

# Display the DataFrame
df.show()`}
            </pre>
          </div>
        </div>
      );
    } else if (activeTab === 'data') {
      return <DataComponent />;
    } else if (activeTab === 'jobs') {
      return (
        <div className="p-4">
          <h3 className="text-lg font-semibold mb-4">Jobs</h3>
          <div className="bg-white rounded shadow p-4">
            <div className="mb-4 flex justify-between items-center">
              <input
                type="text"
                placeholder="Search jobs..."
                className="px-4 py-2 border rounded"
              />
              <button className="px-4 py-2 bg-blue-500 text-white rounded">New Job</button>
            </div>
            <div className="border rounded">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Job Name</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Created</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">Data Processing</td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="px-2 py-1 text-xs rounded bg-green-100 text-green-800">Completed</span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">2023-04-10</td>
                  </tr>
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">ML Training</td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="px-2 py-1 text-xs rounded bg-blue-100 text-blue-800">Running</span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">2023-04-09</td>
                  </tr>
                  <tr className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">Report Generation</td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="px-2 py-1 text-xs rounded bg-red-100 text-red-800">Failed</span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">2023-04-08</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      );
    } else {
      return <div className="p-4">Select a tab to view content</div>;
    }
  };

  return (
    <div className="App">
      <DatabricksUI serviceStatus={servicesStatus} />
    </div>
  );
}

export default App; 