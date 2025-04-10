import cx_Oracle

try:
    connection = cx_Oracle.connect(
        user="sys",
        password="oracle",
        dsn="SQL_PY_Sandbox-oracle:1521/FREE",
        mode=cx_Oracle.SYSDBA
    )
    print("Successfully connected to Oracle Database")
    print("Version:", connection.version)
    connection.close()
except Exception as error:
    print("Error:", str(error))
