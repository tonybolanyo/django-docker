#!/bin/bash

# arranca Django

function manage_app () {
  # Crea y aplica las migraciones
  if [ ${PRODUCTION} == "False" ]; then
    python manage.py makemigrations
  fi
  python manage.py migrate
  # flag for migrations end
  echo "FLAG Created"
  touch /mnt/flags/migration_end
}

function start_development() {
  # Usa el servidor integrado de django para desarrollo
  echo "Launching development server..."
  manage_app
  # If you need launch CELERY...
  # nohup celery -A simulator worker -Q ${MONITOR_QUEUE} -l info &
  # Remote debugging: only one thread is allowed, so no hot reloading available
  # python manage.py runserver --noreload --nothreading 0.0.0.0:8000
  python manage.py runserver 0.0.0.0:8000
  echo "Development server ready!"
}

function start_production() {
  # Usa gunicorn para producción
  echo "Launching production server"
  manage_app
  python manage.py collectstatic --no-input
  # If you need CELERY...
  # nohup celery -A simulator worker -Q ${MONITOR_QUEUE} &
  gunicorn ecosat_api.wsgi:application -w 4 -b 0.0.0.0:8000 --chdir=/usr/src/app --log-file -
  echo "Production server ready!"
}

if [ ${PRODUCTION} == "False" ]; then
  # Si no estamos en producción, arranca versión de desarrollo
  start_development
else
  # Arranca el servidor de producción
  start_production
fi

