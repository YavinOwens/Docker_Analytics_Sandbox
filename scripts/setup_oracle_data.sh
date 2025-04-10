#!/bin/bash

# Script to set up Oracle data files
# This script will download and set up Oracle data files that are too large for GitHub

# Create necessary directories
mkdir -p docker/oracle-ide/oracle-data/{FREE,XE}/{FREEPDB1,XEPDB1,pdbseed}
mkdir -p docker/oracle-ide/oracle-data/{FREE,XE}/dbconfig

# Function to create dummy data files (for testing)
create_dummy_files() {
    local size=$1
    local file=$2
    dd if=/dev/zero of="$file" bs=1M count=$size
}

# Create dummy data files for testing
# In production, these would be downloaded from a secure location
echo "Creating Oracle data files..."

# FREE database files
create_dummy_files 1024 "docker/oracle-ide/oracle-data/FREE/system01.dbf"
create_dummy_files 518 "docker/oracle-ide/oracle-data/FREE/sysaux01.dbf"
create_dummy_files 100 "docker/oracle-ide/oracle-data/FREE/temp01.dbf"
create_dummy_files 100 "docker/oracle-ide/oracle-data/FREE/undotbs01.dbf"
create_dummy_files 100 "docker/oracle-ide/oracle-data/FREE/users01.dbf"

# FREE PDB files
create_dummy_files 378 "docker/oracle-ide/oracle-data/FREE/FREEPDB1/sysaux01.dbf"
create_dummy_files 287 "docker/oracle-ide/oracle-data/FREE/FREEPDB1/system01.dbf"
create_dummy_files 100 "docker/oracle-ide/oracle-data/FREE/FREEPDB1/temp01.dbf"
create_dummy_files 100 "docker/oracle-ide/oracle-data/FREE/FREEPDB1/undotbs01.dbf"
create_dummy_files 100 "docker/oracle-ide/oracle-data/FREE/FREEPDB1/users01.dbf"

# FREE PDB seed files
create_dummy_files 378 "docker/oracle-ide/oracle-data/FREE/pdbseed/sysaux01.dbf"
create_dummy_files 277 "docker/oracle-ide/oracle-data/FREE/pdbseed/system01.dbf"
create_dummy_files 100 "docker/oracle-ide/oracle-data/FREE/pdbseed/temp01.dbf"
create_dummy_files 100 "docker/oracle-ide/oracle-data/FREE/pdbseed/undotbs01.dbf"

# XE database files
create_dummy_files 498 "docker/oracle-ide/oracle-data/XE/system01.dbf"
create_dummy_files 560 "docker/oracle-ide/oracle-data/XE/sysaux01.dbf"

# XE PDB files
create_dummy_files 330 "docker/oracle-ide/oracle-data/XE/XEPDB1/sysaux01.dbf"
create_dummy_files 272 "docker/oracle-ide/oracle-data/XE/XEPDB1/system01.dbf"
create_dummy_files 100 "docker/oracle-ide/oracle-data/XE/XEPDB1/temp01.dbf"
create_dummy_files 100 "docker/oracle-ide/oracle-data/XE/XEPDB1/undotbs01.dbf"
create_dummy_files 100 "docker/oracle-ide/oracle-data/XE/XEPDB1/users01.dbf"

# XE PDB seed files
create_dummy_files 330 "docker/oracle-ide/oracle-data/XE/pdbseed/sysaux01.dbf"
create_dummy_files 272 "docker/oracle-ide/oracle-data/XE/pdbseed/system01.dbf"
create_dummy_files 100 "docker/oracle-ide/oracle-data/XE/pdbseed/temp01.dbf"
create_dummy_files 100 "docker/oracle-ide/oracle-data/XE/pdbseed/undotbs01.dbf"

# Create control files
touch docker/oracle-ide/oracle-data/FREE/control01.ctl
touch docker/oracle-ide/oracle-data/FREE/control02.ctl
touch docker/oracle-ide/oracle-data/XE/control01.ctl
touch docker/oracle-ide/oracle-data/XE/control02.ctl

# Create configuration files
touch docker/oracle-ide/oracle-data/dbconfig/FREE/listener.ora
touch docker/oracle-ide/oracle-data/dbconfig/FREE/sqlnet.ora
touch docker/oracle-ide/oracle-data/dbconfig/FREE/tnsnames.ora
touch docker/oracle-ide/oracle-data/dbconfig/FREE/orapwFREE
touch docker/oracle-ide/oracle-data/dbconfig/FREE/spfileFREE.ora

echo "Oracle data files setup complete!" 