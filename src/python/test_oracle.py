import cx_Oracle

try:
    connection = cx_Oracle.connect(
        user='system',
        password='oracle',
        dsn='oracle:1521/ORCLPDB1'
    )
    print('Successfully connected to Oracle Database')
    print('Version:', connection.version)
    connection.close()
except Exception as error:
    print('Error:', str(error))
