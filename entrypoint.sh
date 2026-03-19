#!/bin/bash

set -e

echo "=== Room Booking System Startup ==="

# Wait for MySQL to be ready
echo "Waiting for MySQL database..."
while ! nc -z "$DB_HOST" "$DB_PORT"; do
  echo "  MySQL is unavailable - sleeping 2s"
  sleep 2
done
echo "MySQL is up and accepting connections!"

# Run database migrations
echo "Running Django migrations..."
python manage.py migrate --run-syncdb --noinput

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Create superuser if environment variables are set
if [ -n "$DJANGO_SUPERUSER_EMAIL" ] && [ -n "$DJANGO_SUPERUSER_PASSWORD" ]; then
  echo "Creating superuser..."
  python manage.py createsuperuser \
    --noinput \
    --email "$DJANGO_SUPERUSER_EMAIL" \
    --first_name "${DJANGO_SUPERUSER_FIRST_NAME:-Admin}" \
    --last_name "${DJANGO_SUPERUSER_LAST_NAME:-User}" \
    2>/dev/null || echo "Superuser already exists, skipping."
fi

echo "Starting Gunicorn server on port 8000..."
exec gunicorn room_booking_system.wsgi:application \
  --bind 0.0.0.0:8000 \
  --workers 3 \
  --timeout 120 \
  --access-logfile - \
  --error-logfile -
