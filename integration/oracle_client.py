import cx_Oracle
from typing import Dict, List, Any
import os

# Configure Oracle client library path
try:
    # Set Oracle environment variables if not already set
    if not os.environ.get('ORACLE_HOME'):
        os.environ['ORACLE_HOME'] = '/opt/oracle/instantclient_21_9'
    if not os.environ.get('LD_LIBRARY_PATH') or '/opt/oracle/instantclient_21_9' not in os.environ.get('LD_LIBRARY_PATH', ''):
        os.environ['LD_LIBRARY_PATH'] = os.environ.get('LD_LIBRARY_PATH', '') + ':/opt/oracle/instantclient_21_9'
    
    # Initialize the Oracle client
    cx_Oracle.init_oracle_client(lib_dir='/opt/oracle/instantclient_21_9')
    print(f"Oracle client initialized successfully: {cx_Oracle.clientversion()}")
except Exception as e:
    print(f"Warning: Could not initialize Oracle client: {str(e)}")

class OracleDBClient:
    def __init__(self):
        # Default connection parameters for the Oracle container
        self.host = "oracle"
        self.port = 1521
        self.service = "XEPDB1"
        self.username = "analytics"
        self.password = "analytics"
        self.connection = None

    def connect(self):
        """Establish a connection to the Oracle database"""
        try:
            dsn = cx_Oracle.makedsn(self.host, self.port, service_name=self.service)
            self.connection = cx_Oracle.connect(user=self.username, password=self.password, dsn=dsn)
            print(f"Connected to Oracle database: {self.host}:{self.port}/{self.service}")
            return True
        except Exception as e:
            print(f"Error connecting to Oracle: {str(e)}")
            return False

    def disconnect(self):
        """Close the Oracle database connection"""
        if self.connection:
            try:
                self.connection.close()
                self.connection = None
                return True
            except Exception as e:
                print(f"Error disconnecting from Oracle: {str(e)}")
                return False
        return True

    def get_tables(self) -> List[Dict[str, str]]:
        """Get all tables and views from the database"""
        if not self.connection and not self.connect():
            raise Exception("Failed to connect to the database")

        cursor = self.connection.cursor()
        try:
            sql = """
            SELECT object_name as name, 
                   object_type as type,
                   owner as schema
            FROM all_objects 
            WHERE object_type IN ('TABLE', 'VIEW')
              AND owner = 'ANALYTICS'
            ORDER BY object_type, object_name
            """
            cursor.execute(sql)
            columns = [col[0].lower() for col in cursor.description]
            tables = []
            for row in cursor:
                table = {}
                for i, col in enumerate(columns):
                    table[col] = row[i]
                # Convert object_type to uppercase for consistency
                if 'type' in table:
                    table['type'] = table['type'].upper()
                tables.append(table)
            return tables
        except Exception as e:
            print(f"Error getting tables: {str(e)}")
            raise
        finally:
            cursor.close()

    def get_table_schema(self, table_name: str) -> List[Dict[str, str]]:
        """Get the schema of a specific table"""
        if not self.connection and not self.connect():
            raise Exception("Failed to connect to the database")

        cursor = self.connection.cursor()
        try:
            # Get column information
            sql = """
            SELECT column_name, 
                   data_type || 
                   CASE 
                       WHEN data_type = 'VARCHAR2' THEN '(' || data_length || ')'
                       WHEN data_type = 'NUMBER' AND data_scale > 0 THEN '(' || data_precision || ',' || data_scale || ')'
                       ELSE ''
                   END as data_type,
                   CASE WHEN nullable = 'Y' THEN 'Y' ELSE 'N' END as nullable,
                   'N' as primary_key
            FROM all_tab_columns
            WHERE table_name = :table_name
              AND owner = 'ANALYTICS'
            ORDER BY column_id
            """
            cursor.execute(sql, {'table_name': table_name.upper()})
            columns = [col[0].lower() for col in cursor.description]
            schema = []
            for row in cursor:
                column = {}
                for i, col in enumerate(columns):
                    column[col] = row[i]
                schema.append(column)
            
            # Get primary key information
            sql_pk = """
            SELECT cols.column_name
            FROM all_constraints cons, all_cons_columns cols
            WHERE cons.constraint_type = 'P'
              AND cons.constraint_name = cols.constraint_name
              AND cons.owner = cols.owner
              AND cons.table_name = :table_name
              AND cons.owner = 'ANALYTICS'
            """
            cursor.execute(sql_pk, {'table_name': table_name.upper()})
            pk_columns = [row[0] for row in cursor]
            
            # Update primary key flag
            for column in schema:
                if column['column_name'] in pk_columns:
                    column['primary_key'] = 'Y'
            
            return schema
        except Exception as e:
            print(f"Error getting table schema: {str(e)}")
            raise
        finally:
            cursor.close()

    def execute_query(self, query: str) -> Dict[str, Any]:
        """Execute a SQL query and return the results"""
        if not self.connection and not self.connect():
            raise Exception("Failed to connect to the database")

        cursor = self.connection.cursor()
        try:
            cursor.execute(query)
            
            result = {"columns": [], "rows": []}
            
            # Get column names
            if cursor.description:
                result["columns"] = [col[0] for col in cursor.description]
            
            # Get data rows
            rows = cursor.fetchall()
            result["rows"] = [list(row) for row in rows]
            
            return result
        except Exception as e:
            print(f"Error executing query: {str(e)}")
            raise
        finally:
            cursor.close()

# Create a singleton instance
oracle_client = OracleDBClient() 