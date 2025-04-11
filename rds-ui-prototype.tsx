import React, { useState, useEffect } from 'react';

interface ConnectionConfig {
  host: string;
  port: number;
  service: string;
  username: string;
  password: string;
}

interface QueryResult {
  columns: string[];
  rows: any[][];
}

const RDSPrototype: React.FC = () => {
  const [connectionConfig, setConnectionConfig] = useState<ConnectionConfig>({
    host: 'oracle',
    port: 1521,
    service: 'XE',
    username: 'analytics',
    password: 'analytics'
  });
  
  const [query, setQuery] = useState<string>('SELECT * FROM dual');
  const [results, setResults] = useState<QueryResult | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    
    if (name in connectionConfig) {
      setConnectionConfig({
        ...connectionConfig,
        [name]: name === 'port' ? parseInt(value, 10) : value
      });
    } else if (name === 'query') {
      setQuery(value);
    }
  };

  const executeQuery = async () => {
    setLoading(true);
    setError(null);
    
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
        throw new Error(`Server returned ${response.status}: ${response.statusText}`);
      }
      
      const data = await response.json();
      setResults(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An unknown error occurred');
      setResults(null);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="rds-prototype">
      <h1>RDS Oracle Integration Prototype</h1>
      
      <div className="connection-config">
        <h2>Connection Configuration</h2>
        <div className="form-group">
          <label>Host:</label>
          <input
            type="text"
            name="host"
            value={connectionConfig.host}
            onChange={handleInputChange}
          />
        </div>
        <div className="form-group">
          <label>Port:</label>
          <input
            type="number"
            name="port"
            value={connectionConfig.port}
            onChange={handleInputChange}
          />
        </div>
        <div className="form-group">
          <label>Service:</label>
          <input
            type="text"
            name="service"
            value={connectionConfig.service}
            onChange={handleInputChange}
          />
        </div>
        <div className="form-group">
          <label>Username:</label>
          <input
            type="text"
            name="username"
            value={connectionConfig.username}
            onChange={handleInputChange}
          />
        </div>
        <div className="form-group">
          <label>Password:</label>
          <input
            type="password"
            name="password"
            value={connectionConfig.password}
            onChange={handleInputChange}
          />
        </div>
      </div>
      
      <div className="query-section">
        <h2>SQL Query</h2>
        <textarea
          name="query"
          value={query}
          onChange={handleInputChange}
          rows={5}
          placeholder="Enter SQL query..."
        />
        <button onClick={executeQuery} disabled={loading}>
          {loading ? 'Executing...' : 'Execute Query'}
        </button>
      </div>
      
      {error && (
        <div className="error-message">
          <h3>Error</h3>
          <p>{error}</p>
        </div>
      )}
      
      {results && (
        <div className="results-section">
          <h2>Query Results</h2>
          <table>
            <thead>
              <tr>
                {results.columns.map((column, index) => (
                  <th key={index}>{column}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {results.rows.map((row, rowIndex) => (
                <tr key={rowIndex}>
                  {row.map((cell, cellIndex) => (
                    <td key={cellIndex}>{cell?.toString() || 'NULL'}</td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default RDSPrototype; 