import os
import sys
import cx_Oracle

print("Python version:", sys.version)
print("cx_Oracle version:", cx_Oracle.version)
print("LD_LIBRARY_PATH:", os.environ.get('LD_LIBRARY_PATH'))
print("ORACLE_HOME:", os.environ.get('ORACLE_HOME'))

try:
    print("Attempting to initialize Oracle client...")
    client_version = cx_Oracle.clientversion()
    print("Oracle client version:", client_version)
except Exception as e:
    print("Error initializing Oracle client:", str(e))
    print("Error type:", type(e).__name__)
    import traceback
    traceback.print_exc()
