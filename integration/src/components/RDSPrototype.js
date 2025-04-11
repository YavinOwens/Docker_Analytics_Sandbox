import React, { useState } from 'react';

const RDSPrototype = () => {
  const [connectionConfig, setConnectionConfig] = useState({
    host: 'oracle',
    port: 1521,
    service: 'XE',
    username: 'analytics',
    password: '••••••••'
  });

  const [query, setQuery] = useState('SELECT * FROM dual');
  const [queryResult, setQueryResult] = useState({ columns: ['DUMMY'], rows: [['X']] });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const executeQuery = async () => {
    setLoading(true);
    try {
      const response = await fetch('http://localhost:8000/execute-query', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          connection: connectionConfig,
          query: query
        }),
      });

      if (!response.ok) {
        throw new Error(`Error: ${response.status}`);
      }

      const data = await response.json();
      setQueryResult(data);
    } catch (err) {
      setError(err.message);
      console.error('Query execution failed:', err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-5 max-w-4xl">
      <h1 className="text-xl font-bold mb-4">RDS Oracle Integration Prototype</h1>
      
      <div className="mb-6">
        <h2 className="text-lg font-medium mb-2">Connection Configuration</h2>
        <div className="space-y-2">
          <div>
            <label className="block text-sm">Host:</label>
            <span>{connectionConfig.host}</span>
          </div>
          <div>
            <label className="block text-sm">Port:</label>
            <span>{connectionConfig.port}</span>
          </div>
          <div>
            <label className="block text-sm">Service:</label>
            <span>{connectionConfig.service}</span>
          </div>
          <div>
            <label className="block text-sm">Username:</label>
            <span>{connectionConfig.username}</span>
          </div>
          <div>
            <label className="block text-sm">Password:</label>
            <span>{connectionConfig.password}</span>
          </div>
        </div>
      </div>
      
      <div className="mb-6">
        <h2 className="text-lg font-medium mb-2">SQL Query</h2>
        <textarea 
          className="w-full p-2 border rounded mb-2"
          rows={3}
          value={query}
          onChange={(e) => setQuery(e.target.value)}
        />
        <button 
          className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
          onClick={executeQuery}
          disabled={loading}
        >
          {loading ? 'Executing...' : 'Execute Query'}
        </button>
      </div>
      
      {error && (
        <div className="mb-6 p-3 bg-red-100 text-red-700 rounded">
          {error}
        </div>
      )}
      
      <div>
        <h2 className="text-lg font-medium mb-2">Query Results</h2>
        <div className="border rounded overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                {queryResult.columns && queryResult.columns.map((column, index) => (
                  <th key={index} className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    {column}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {queryResult.rows && queryResult.rows.map((row, rowIndex) => (
                <tr key={rowIndex}>
                  {row.map((cell, cellIndex) => (
                    <td key={cellIndex} className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {cell}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default RDSPrototype; 