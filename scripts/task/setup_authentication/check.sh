#!/bin/bash
set -e
test -f /root/test_connection.py
/root/hiddenlayer-env/bin/python -c "import hiddenlayer" 2>/dev/null
