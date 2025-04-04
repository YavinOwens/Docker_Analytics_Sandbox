import csv
import sys

def fix_csv(input_file, output_file):
    with open(input_file, "r") as f:
        content = f.read()
    lines = content.replace("\n", "").split(",")
    rows = [lines[i:i+9] for i in range(0, len(lines), 9)]
    with open(output_file, "w") as f:
        writer = csv.writer(f)
        writer.writerows(rows)

fix_csv("/opt/oracle/scripts/data/industrial_iot_data.csv", "/opt/oracle/scripts/data/industrial_iot_data_fixed.csv")
fix_csv("/opt/oracle/scripts/data/industrial_maintenance.csv", "/opt/oracle/scripts/data/industrial_maintenance_fixed.csv")
fix_csv("/opt/oracle/scripts/data/industrial_safety.csv", "/opt/oracle/scripts/data/industrial_safety_fixed.csv") 