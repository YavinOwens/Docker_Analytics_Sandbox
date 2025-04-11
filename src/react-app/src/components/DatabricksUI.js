import React, { useState } from 'react';
import DataComponent from './DataComponent';
import ReposComponent from './ReposComponent';

const DatabricksUI = ({ serviceStatus }) => {
  const [activeTab, setActiveTab] = useState('notebook');
  const [sidebarExpanded, setSidebarExpanded] = useState(true);
  const [code, setCode] = useState("# Example Python cell\nimport pyspark.sql.functions as F\n\n# Create a sample DataFrame\ndf = spark.createDataFrame([\n  (1, 'John', 35),\n  (2, 'Alice', 28),\n  (3, 'Bob', 42)\n], ['id', 'name', 'age'])\n\n# Display the DataFrame\ndisplay(df)");
  
  const toggleSidebar = () => setSidebarExpanded(!sidebarExpanded);

  // Render the appropriate component based on the active tab
  const renderContent = () => {
    if (activeTab === 'data') {
      return <DataComponent />;
    } else if (activeTab === 'repos') {
      return <ReposComponent />;
    } else if (activeTab === 'notebook') {
      return (
        <div>
          <div className="mb-8">
            <h1 className="text-2xl font-bold mb-2">Customer Segmentation Analysis</h1>
            <div className="text-sm text-gray-500">
              Last edited: 2 hours ago by John Doe
            </div>
          </div>
          
          {/* Command cells */}
          <div className="mb-6">
            <div className="flex items-center text-sm text-gray-600 mb-2">
              <div className="bg-gray-200 rounded-md px-2 py-1 mr-2">Cmd 1</div>
              <div>Python</div>
            </div>
            <div className="border rounded-md">
              <div className="bg-gray-50 p-2 border-b">
                <textarea 
                  className="w-full bg-gray-50 outline-none resize-none font-mono text-sm"
                  rows={10}
                  value={code}
                  onChange={(e) => setCode(e.target.value)}
                />
              </div>
              <div className="p-4 bg-white">
                <div className="text-sm text-gray-500 mb-2">Output:</div>
                <div className="border rounded overflow-hidden">
                  <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                      <tr>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">id</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">name</th>
                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">age</th>
                      </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                      <tr>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">1</td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">John</td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">35</td>
                      </tr>
                      <tr>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">2</td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">Alice</td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">28</td>
                      </tr>
                      <tr>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">3</td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">Bob</td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">42</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>

          <div className="mb-6">
            <div className="flex items-center text-sm text-gray-600 mb-2">
              <div className="bg-gray-200 rounded-md px-2 py-1 mr-2">Cmd 2</div>
              <div>Python</div>
            </div>
            <div className="border rounded-md p-2 bg-gray-50 cursor-text h-12">
              <div className="text-gray-400 text-sm">Add code here...</div>
            </div>
          </div>
        </div>
      );
    } else if (activeTab === 'jobs') {
      return (
        <div>
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-xl font-bold">Scheduled Jobs</h2>
            <button className="bg-blue-600 text-white px-4 py-2 rounded">Create Job</button>
          </div>

          <div className="border rounded-md overflow-hidden">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Schedule</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Last Run</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                <tr>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">Daily ETL Pipeline</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">Daily @ 2:00 AM</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">Apr 11, 2025 2:00 AM</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">Success</span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <button className="text-blue-600 hover:text-blue-800">Run Now</button>
                  </td>
                </tr>
                <tr>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">Dashboard Refresh</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">Hourly</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">Apr 11, 2025 9:00 AM</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">Running</span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <button className="text-gray-400 cursor-not-allowed">Run Now</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      );
    } else if (activeTab === 'dashboard') {
      return (
        <div>
          <h2 className="text-xl font-bold mb-4">Dashboard View</h2>
          <div className="grid grid-cols-2 gap-6">
            <div className="border rounded-md p-4 bg-white shadow-sm">
              <h3 className="text-lg font-medium mb-2">Customer Distribution</h3>
              <div className="h-64 bg-gray-100 rounded flex items-center justify-center">
                <div className="text-gray-500">Pie Chart Visualization</div>
              </div>
            </div>
            <div className="border rounded-md p-4 bg-white shadow-sm">
              <h3 className="text-lg font-medium mb-2">Revenue by Segment</h3>
              <div className="h-64 bg-gray-100 rounded flex items-center justify-center">
                <div className="text-gray-500">Bar Chart Visualization</div>
              </div>
            </div>
          </div>
        </div>
      );
    } else {
      return <div className="p-4">Select a tab to view content</div>;
    }
  };

  return (
    <div className="flex flex-col h-screen bg-gray-100">
      {/* Top navigation bar */}
      <div className="flex items-center h-12 bg-blue-700 text-white px-4">
        <div className="flex items-center space-x-2">
          <div className="font-bold text-lg">RDS</div>
        </div>
        <div className="ml-10 flex space-x-6">
          <div className="font-medium">Compute</div>
          <div className="font-medium">Data</div>
          <div className="font-medium">Machine Learning</div>
          <div className="font-medium">SQL</div>
          <div className="font-medium">Admin</div>
        </div>
        <div className="ml-auto flex items-center space-x-4">
          {/* Service Status Indicators */}
          <div className="flex items-center space-x-2">
            <span className={`inline-block w-3 h-3 rounded-full ${
              serviceStatus?.integration?.status === 'online' ? 'bg-green-500' : 
              serviceStatus?.integration?.status === 'offline' ? 'bg-red-500' : 'bg-yellow-500'
            }`} title={serviceStatus?.integration?.message || 'Integration Service'}></span>
            <span className={`inline-block w-3 h-3 rounded-full ${
              serviceStatus?.oracle?.status === 'online' ? 'bg-green-500' : 
              serviceStatus?.oracle?.status === 'offline' ? 'bg-red-500' : 'bg-yellow-500'
            }`} title={serviceStatus?.oracle?.message || 'Oracle Database'}></span>
            <span className={`inline-block w-3 h-3 rounded-full ${
              serviceStatus?.minio?.status === 'online' ? 'bg-green-500' : 
              serviceStatus?.minio?.status === 'offline' ? 'bg-red-500' : 'bg-yellow-500'
            }`} title={serviceStatus?.minio?.message || 'MinIO Storage'}></span>
          </div>
          <div className="w-6 h-6 bg-blue-600 rounded-full flex items-center justify-center">
            <span className="text-xs">JD</span>
          </div>
        </div>
      </div>

      {/* Workspace area */}
      <div className="flex flex-1 overflow-hidden">
        {/* Left sidebar */}
        <div className={`bg-gray-800 text-gray-300 transition-all ${sidebarExpanded ? 'w-64' : 'w-16'}`}>
          <div className="p-4">
            <div className="flex items-center justify-between">
              <span className={sidebarExpanded ? 'block' : 'hidden'}>Workspace</span>
              <button 
                onClick={toggleSidebar}
                className="bg-gray-700 rounded p-1"
              >
                {sidebarExpanded ? '◀' : '▶'}
              </button>
            </div>
          </div>
          <div className="mt-4">
            <div className="px-4 py-2 hover:bg-gray-700 cursor-pointer" onClick={() => setActiveTab('repos')}>
              {sidebarExpanded ? 'Repos' : '📁'}
            </div>
            <div className="px-4 py-2 hover:bg-gray-700 cursor-pointer">
              {sidebarExpanded ? 'Users' : '👤'}
            </div>
            <div className="px-4 py-2 bg-gray-700 cursor-pointer">
              {sidebarExpanded ? 'My Projects' : '📊'}
            </div>
            {sidebarExpanded && (
              <div className="ml-4">
                <div className="px-4 py-2 hover:bg-gray-700 cursor-pointer">Data Analysis</div>
                <div className="px-4 py-2 hover:bg-gray-700 cursor-pointer">ML Pipeline</div>
                <div className="px-4 py-2 hover:bg-gray-700 cursor-pointer text-white font-medium">Customer Segmentation</div>
              </div>
            )}
          </div>
        </div>

        {/* Main content area */}
        <div className="flex-1 flex flex-col">
          {/* Tabs */}
          <div className="flex bg-white border-b">
            <div 
              className={`px-6 py-3 font-medium cursor-pointer ${activeTab === 'notebook' ? 'border-b-2 border-blue-600 text-blue-600' : 'text-gray-600'}`}
              onClick={() => setActiveTab('notebook')}
            >
              Notebook
            </div>
            <div 
              className={`px-6 py-3 font-medium cursor-pointer ${activeTab === 'dashboard' ? 'border-b-2 border-blue-600 text-blue-600' : 'text-gray-600'}`}
              onClick={() => setActiveTab('dashboard')}
            >
              Dashboard
            </div>
            <div 
              className={`px-6 py-3 font-medium cursor-pointer ${activeTab === 'data' ? 'border-b-2 border-blue-600 text-blue-600' : 'text-gray-600'}`}
              onClick={() => setActiveTab('data')}
            >
              Data
            </div>
            <div 
              className={`px-6 py-3 font-medium cursor-pointer ${activeTab === 'jobs' ? 'border-b-2 border-blue-600 text-blue-600' : 'text-gray-600'}`}
              onClick={() => setActiveTab('jobs')}
            >
              Jobs
            </div>
          </div>

          {/* Content area */}
          <div className="flex-1 overflow-auto p-6 bg-white">
            {renderContent()}
          </div>
        </div>

        {/* Right sidebar (cluster info) */}
        <div className="w-72 bg-gray-50 border-l p-4">
          <h3 className="font-medium text-gray-700 mb-4">Cluster Details</h3>
          <div className="bg-white rounded-md border p-3 mb-4">
            <div className="flex items-center mb-2">
              <div className="w-3 h-3 bg-green-500 rounded-full mr-2"></div>
              <div className="font-medium">Running</div>
            </div>
            <div className="text-sm text-gray-600 mb-1">Standard_Cluster</div>
            <div className="text-xs text-gray-500">4 Workers, 32GB Memory</div>
          </div>

          <div className="border-t pt-4 mt-4">
            <h3 className="font-medium text-gray-700 mb-2">Service Status</h3>
            <div className="text-sm">
              <div className="flex justify-between mb-1">
                <div className="text-gray-600">Integration:</div>
                <div className={`${
                  serviceStatus?.integration?.status === 'online' ? 'text-green-600' : 
                  serviceStatus?.integration?.status === 'offline' ? 'text-red-600' : 'text-yellow-600'
                }`}>
                  {serviceStatus?.integration?.status === 'online' ? 'Online' : 
                   serviceStatus?.integration?.status === 'offline' ? 'Offline' : 'Mock Data'}
                </div>
              </div>
              <div className="flex justify-between mb-1">
                <div className="text-gray-600">Oracle DB:</div>
                <div className={`${
                  serviceStatus?.oracle?.status === 'online' ? 'text-green-600' : 
                  serviceStatus?.oracle?.status === 'offline' ? 'text-red-600' : 'text-yellow-600'
                }`}>
                  {serviceStatus?.oracle?.status === 'online' ? 'Online' : 
                   serviceStatus?.oracle?.status === 'offline' ? 'Offline' : 'Mock Data'}
                </div>
              </div>
              <div className="flex justify-between">
                <div className="text-gray-600">MinIO:</div>
                <div className={`${
                  serviceStatus?.minio?.status === 'online' ? 'text-green-600' : 
                  serviceStatus?.minio?.status === 'offline' ? 'text-red-600' : 'text-yellow-600'
                }`}>
                  {serviceStatus?.minio?.status === 'online' ? 'Online' : 
                   serviceStatus?.minio?.status === 'offline' ? 'Offline' : 'Mock Data'}
                </div>
              </div>
            </div>
          </div>

          <div className="border-t pt-4 mt-4">
            <h3 className="font-medium text-gray-700 mb-2">Notebook Settings</h3>
            <div className="flex flex-col space-y-2 text-sm">
              <button className="text-blue-600 hover:text-blue-800 text-left">
                Revision History
              </button>
              <button className="text-blue-600 hover:text-blue-800 text-left">
                Permissions
              </button>
              <button className="text-blue-600 hover:text-blue-800 text-left">
                Export
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DatabricksUI; 