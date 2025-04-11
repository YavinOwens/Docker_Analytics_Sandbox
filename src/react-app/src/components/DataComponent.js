import React, { useState, useEffect } from 'react';
import { OracleClient } from '../services/oracleClient';

const DataComponent = () => {
  const [tables, setTables] = useState([]);
  const [selectedTable, setSelectedTable] = useState(null);
  const [tableSchema, setTableSchema] = useState([]);
  const [tableData, setTableData] = useState({ columns: [], rows: [] });
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [sqlQuery, setSqlQuery] = useState('');

  // Fetch tables on component mount
  useEffect(() => {
    fetchTables();
  }, []);

  // Fetch table schema when a table is selected
  useEffect(() => {
    if (selectedTable) {
      fetchTableSchema(selectedTable);
      // Default SQL query when selecting a table
      const defaultQuery = `SELECT * FROM ${selectedTable}`;
      setSqlQuery(defaultQuery);
      executeQuery(defaultQuery);
    }
  }, [selectedTable]);

  // Fetch tables from Oracle
  const fetchTables = async () => {
    try {
      setLoading(true);
      setError(null);
      const tableList = await OracleClient.getTables();
      setTables(tableList);
    } catch (err) {
      setError('Failed to fetch tables: ' + err.message);
      console.error('Error fetching tables:', err);
    } finally {
      setLoading(false);
    }
  };

  // Fetch table schema
  const fetchTableSchema = async (tableName) => {
    try {
      setLoading(true);
      setError(null);
      const schema = await OracleClient.getTableSchema(tableName);
      setTableSchema(schema);
    } catch (err) {
      setError('Failed to fetch table schema: ' + err.message);
      console.error('Error fetching table schema:', err);
    } finally {
      setLoading(false);
    }
  };

  // Execute SQL query
  const executeQuery = async (query) => {
    try {
      setLoading(true);
      setError(null);
      const result = await OracleClient.executeQuery(query);
      setTableData(result);
    } catch (err) {
      setError('Failed to execute query: ' + err.message);
      console.error('Error executing query:', err);
    } finally {
      setLoading(false);
    }
  };

  // Handle search input change
  const handleSearchChange = (e) => {
    setSearchQuery(e.target.value);
  };

  // Filter tables based on search query
  const filteredTables = tables.filter(table => 
    table.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    table.type.toLowerCase().includes(searchQuery.toLowerCase()) ||
    table.schema.toLowerCase().includes(searchQuery.toLowerCase())
  );

  // Handle table selection
  const handleTableClick = (tableName) => {
    setSelectedTable(tableName);
  };

  // Handle SQL query input change
  const handleSqlQueryChange = (e) => {
    setSqlQuery(e.target.value);
  };

  // Handle SQL query execution
  const handleQueryExecution = (e) => {
    e.preventDefault();
    if (sqlQuery.trim()) {
      executeQuery(sqlQuery);
    }
  };

  return (
    <div className="p-4">
      <h3 className="text-lg font-semibold mb-4">Oracle Database Explorer</h3>
      
      {/* Error Display */}
      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        {/* Left Panel: Tables List */}
        <div className="bg-white rounded shadow p-4">
          <div className="mb-4">
            <h4 className="text-md font-semibold mb-2">Tables & Views</h4>
            <input
              type="text"
              placeholder="Search tables..."
              className="w-full px-4 py-2 border rounded"
              value={searchQuery}
              onChange={handleSearchChange}
            />
          </div>
          
          {loading && !selectedTable ? (
            <div className="flex justify-center items-center h-64">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
            </div>
          ) : (
            <div className="overflow-y-auto max-h-96 border rounded">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                    <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
                    <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Schema</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {filteredTables.map((table, index) => (
                    <tr 
                      key={index}
                      onClick={() => handleTableClick(table.name)}
                      className={`cursor-pointer hover:bg-gray-50 ${selectedTable === table.name ? 'bg-blue-50' : ''}`}
                    >
                      <td className="px-4 py-2 whitespace-nowrap text-sm">{table.name}</td>
                      <td className="px-4 py-2 whitespace-nowrap text-sm">
                        <span className={`px-2 py-1 text-xs rounded ${
                          table.type === 'TABLE' ? 'bg-green-100 text-green-800' : 'bg-purple-100 text-purple-800'
                        }`}>
                          {table.type}
                        </span>
                      </td>
                      <td className="px-4 py-2 whitespace-nowrap text-sm">{table.schema}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>

        {/* Middle Panel: Table Schema */}
        <div className="bg-white rounded shadow p-4">
          <h4 className="text-md font-semibold mb-2">
            {selectedTable ? `${selectedTable} Schema` : 'Select a table to view schema'}
          </h4>
          
          {selectedTable && loading && tableSchema.length === 0 ? (
            <div className="flex justify-center items-center h-64">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
            </div>
          ) : selectedTable ? (
            <div className="overflow-y-auto max-h-96 border rounded">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Column</th>
                    <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
                    <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Nullable</th>
                    <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Key</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {tableSchema.map((column, index) => (
                    <tr key={index}>
                      <td className="px-4 py-2 whitespace-nowrap text-sm font-medium">
                        {column.column_name}
                      </td>
                      <td className="px-4 py-2 whitespace-nowrap text-sm">
                        {column.data_type}
                      </td>
                      <td className="px-4 py-2 whitespace-nowrap text-sm">
                        {column.nullable === 'Y' ? 'Yes' : 'No'}
                      </td>
                      <td className="px-4 py-2 whitespace-nowrap text-sm">
                        {column.primary_key === 'Y' ? (
                          <span className="px-2 py-1 text-xs rounded bg-yellow-100 text-yellow-800">PK</span>
                        ) : ''}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <div className="flex justify-center items-center h-64 text-gray-500">
              No table selected
            </div>
          )}
        </div>

        {/* Right Panel: SQL Editor */}
        <div className="bg-white rounded shadow p-4">
          <h4 className="text-md font-semibold mb-2">SQL Query</h4>
          
          <form onSubmit={handleQueryExecution}>
            <div className="mb-4">
              <textarea
                className="w-full px-4 py-2 border rounded font-mono text-sm"
                rows="5"
                placeholder="Enter SQL query..."
                value={sqlQuery}
                onChange={handleSqlQueryChange}
              ></textarea>
            </div>
            <div className="mb-4">
              <button
                type="submit"
                className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
                disabled={loading}
              >
                {loading ? 'Executing...' : 'Run Query'}
              </button>
            </div>
          </form>
        </div>
      </div>

      {/* Results Area */}
      <div className="mt-4 bg-white rounded shadow p-4">
        <h4 className="text-md font-semibold mb-2">Query Results</h4>
        
        {loading && tableData.columns.length === 0 && tableData.rows.length === 0 ? (
          <div className="flex justify-center items-center h-64">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
          </div>
        ) : tableData.columns.length > 0 ? (
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  {tableData.columns.map((column, index) => (
                    <th 
                      key={index}
                      className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase"
                    >
                      {column}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {tableData.rows.map((row, rowIndex) => (
                  <tr key={rowIndex}>
                    {row.map((cell, cellIndex) => (
                      <td 
                        key={cellIndex}
                        className="px-4 py-2 whitespace-nowrap text-sm"
                      >
                        {cell}
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : tableData.message ? (
          <div className="p-4 text-gray-500">{tableData.message}</div>
        ) : (
          <div className="p-4 text-gray-500">Run a query to see results</div>
        )}
      </div>
    </div>
  );
};

export default DataComponent; 