#!/bin/bash

# wait for Postgres to start
function postgres_ready() {
python << END
import sys
import psycopg2
import os

DB_HOST = os.environ.get('SQL_HOST', 'db')
DB_PORT = os.environ.get('SQL_PORT', '5432')
DB_NAME = os.environ.get('SQL_DATABASE', 'postgres')
DB_USER = os.environ.get('SQL_USER', 'postgres')
DB_PASSWORD = os.environ.get('SQL_PASSWORD', 'postgres')

print('Intento de conexion DB:', DB_NAME)

try:
    conn = psycopg2.connect(
        dbname=DB_NAME, host=DB_HOST, port=DB_PORT,
        user=DB_USER, password=DB_PASSWORD)
except psycopg2.OperationalError:
    sys.exit(-1)
sys.exit(0)
END
}

until postgres_ready; do
  >&2 echo "Postgres is NOT ready - waiting..."
  sleep 1
done

# Start app
>&2 echo "Postgres is READY - run django"

/start.sh
