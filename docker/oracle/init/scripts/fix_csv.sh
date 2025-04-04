#!/bin/bash
tr -d '\n' | sed 's/device_id/\ndevice_id/g' | sed 's/DEV_/\nDEV_/g' | sed 's/MAINT_/\nMAINT_/g' | sed 's/SAFE_/\nSAFE_/g' 