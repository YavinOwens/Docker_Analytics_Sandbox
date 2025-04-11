// Oracle database client using fetch API to communicate with the backend
const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000';

export const OracleClient = {
  // Fetch tables from Oracle database
  async getTables() {
    try {
      console.log('Fetching tables from Oracle database');
      console.log('Using API URL:', API_URL);
      
      // Use the backend API to fetch tables
      const response = await fetch(`${API_URL}/api/oracle/tables`, {
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        }
      });
      
      // Check for HTTP errors
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.detail || 'Failed to fetch tables');
      }
      
      return await response.json();
    } catch (error) {
      console.error('Error fetching tables:', error);
      
      // Fall back to mock data if API call fails
      return [
        { name: 'CUSTOMERS', type: 'TABLE', schema: 'ANALYTICS' },
        { name: 'ORDERS', type: 'TABLE', schema: 'ANALYTICS' },
        { name: 'PRODUCTS', type: 'TABLE', schema: 'ANALYTICS' },
        { name: 'EMPLOYEES', type: 'TABLE', schema: 'ANALYTICS' },
        { name: 'SALES', type: 'TABLE', schema: 'ANALYTICS' },
        { name: 'INVENTORY', type: 'TABLE', schema: 'ANALYTICS' },
        { name: 'ORDER_ITEMS', type: 'VIEW', schema: 'ANALYTICS' },
        { name: 'CUSTOMER_METRICS', type: 'VIEW', schema: 'ANALYTICS' }
      ];
    }
  },
  
  // Fetch table schema
  async getTableSchema(tableName) {
    try {
      console.log(`Fetching schema for table: ${tableName}`);
      
      // Use the backend API to fetch table schema
      const response = await fetch(`${API_URL}/api/oracle/tables/${tableName}/schema`);
      
      // Check for HTTP errors
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.detail || 'Failed to fetch table schema');
      }
      
      return await response.json();
    } catch (error) {
      console.error(`Error fetching schema for table ${tableName}:`, error);
      
      // Fall back to mock data if API call fails
      const schemas = {
        'CUSTOMERS': [
          { column_name: 'CUSTOMER_ID', data_type: 'NUMBER', nullable: 'N', primary_key: 'Y' },
          { column_name: 'NAME', data_type: 'VARCHAR2(100)', nullable: 'N', primary_key: 'N' },
          { column_name: 'EMAIL', data_type: 'VARCHAR2(100)', nullable: 'Y', primary_key: 'N' },
          { column_name: 'PHONE', data_type: 'VARCHAR2(20)', nullable: 'Y', primary_key: 'N' },
          { column_name: 'ADDRESS', data_type: 'VARCHAR2(200)', nullable: 'Y', primary_key: 'N' },
          { column_name: 'CREATED_DATE', data_type: 'DATE', nullable: 'N', primary_key: 'N' }
        ],
        'ORDERS': [
          { column_name: 'ORDER_ID', data_type: 'NUMBER', nullable: 'N', primary_key: 'Y' },
          { column_name: 'CUSTOMER_ID', data_type: 'NUMBER', nullable: 'N', primary_key: 'N' },
          { column_name: 'ORDER_DATE', data_type: 'DATE', nullable: 'N', primary_key: 'N' },
          { column_name: 'STATUS', data_type: 'VARCHAR2(20)', nullable: 'N', primary_key: 'N' },
          { column_name: 'TOTAL_AMOUNT', data_type: 'NUMBER(10,2)', nullable: 'N', primary_key: 'N' }
        ],
        'PRODUCTS': [
          { column_name: 'PRODUCT_ID', data_type: 'NUMBER', nullable: 'N', primary_key: 'Y' },
          { column_name: 'NAME', data_type: 'VARCHAR2(100)', nullable: 'N', primary_key: 'N' },
          { column_name: 'DESCRIPTION', data_type: 'VARCHAR2(500)', nullable: 'Y', primary_key: 'N' },
          { column_name: 'PRICE', data_type: 'NUMBER(10,2)', nullable: 'N', primary_key: 'N' },
          { column_name: 'CATEGORY', data_type: 'VARCHAR2(50)', nullable: 'Y', primary_key: 'N' },
          { column_name: 'INVENTORY_COUNT', data_type: 'NUMBER', nullable: 'Y', primary_key: 'N' }
        ]
      };
      
      return schemas[tableName] || [];
    }
  },
  
  // Execute a SQL query
  async executeQuery(query) {
    try {
      console.log(`Executing query: ${query}`);
      
      // Use the backend API to execute the query
      const response = await fetch(`${API_URL}/api/oracle/query`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ query }),
      });
      
      // Check for HTTP errors
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.detail || 'Failed to execute query');
      }
      
      return await response.json();
    } catch (error) {
      console.error('Error executing query:', error);
      
      // Fall back to mock data if API call fails
      if (query.toLowerCase().includes('select * from customers')) {
        return {
          columns: ['CUSTOMER_ID', 'NAME', 'EMAIL', 'PHONE', 'ADDRESS', 'CREATED_DATE'],
          rows: [
            [1, 'John Doe', 'john.doe@example.com', '555-1234', '123 Main St', '2023-01-15'],
            [2, 'Jane Smith', 'jane.smith@example.com', '555-5678', '456 Oak Ave', '2023-02-20'],
            [3, 'Bob Johnson', 'bob.johnson@example.com', '555-9012', '789 Pine Rd', '2023-03-10'],
            [4, 'Alice Brown', 'alice.brown@example.com', '555-3456', '321 Elm St', '2023-04-05'],
            [5, 'Charlie Davis', 'charlie.davis@example.com', '555-7890', '654 Maple Dr', '2023-05-12']
          ]
        };
      } else if (query.toLowerCase().includes('select * from orders')) {
        return {
          columns: ['ORDER_ID', 'CUSTOMER_ID', 'ORDER_DATE', 'STATUS', 'TOTAL_AMOUNT'],
          rows: [
            [101, 1, '2023-06-10', 'DELIVERED', 125.50],
            [102, 2, '2023-06-11', 'SHIPPED', 75.20],
            [103, 3, '2023-06-12', 'PROCESSING', 220.00],
            [104, 1, '2023-06-15', 'DELIVERED', 45.99],
            [105, 4, '2023-06-18', 'PENDING', 150.75]
          ]
        };
      } else if (query.toLowerCase().includes('select * from products')) {
        return {
          columns: ['PRODUCT_ID', 'NAME', 'DESCRIPTION', 'PRICE', 'CATEGORY', 'INVENTORY_COUNT'],
          rows: [
            [201, 'Laptop Pro', 'High-performance laptop', 1299.99, 'Electronics', 45],
            [202, 'Smartphone X', '5G smartphone with camera', 799.99, 'Electronics', 120],
            [203, 'Coffee Maker', 'Automatic coffee machine', 129.50, 'Kitchen', 78],
            [204, 'Wireless Headphones', 'Noise-cancelling headphones', 199.99, 'Audio', 65],
            [205, 'Fitness Tracker', 'Tracks steps and heart rate', 89.99, 'Wearables', 200]
          ]
        };
      } else {
        return {
          columns: [],
          rows: [],
          message: 'No data returned or query not recognized'
        };
      }
    }
  }
}; 