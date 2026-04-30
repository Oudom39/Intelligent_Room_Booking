from django.db import migrations


def _drop_room_number_index(apps, schema_editor):
    vendor = schema_editor.connection.vendor
    cursor = schema_editor.connection.cursor()

    if vendor == 'sqlite':
        # SQLite: DROP INDEX is global (no ALTER TABLE syntax)
        cursor.execute("DROP INDEX IF EXISTS room_number;")
    else:
        # MySQL/Postgres compatible DROP for named index on table
        cursor.execute("ALTER TABLE rooms DROP INDEX room_number;")


def _create_room_number_index(apps, schema_editor):
    vendor = schema_editor.connection.vendor
    cursor = schema_editor.connection.cursor()

    if vendor == 'sqlite':
        cursor.execute("CREATE UNIQUE INDEX IF NOT EXISTS room_number ON rooms (room_number);")
    else:
        cursor.execute("CREATE UNIQUE INDEX room_number ON rooms (room_number);")


class Migration(migrations.Migration):
    dependencies = [
        ("booking", "0006_alter_room_room_number"),
    ]

    operations = [
        migrations.RunPython(_drop_room_number_index, _create_room_number_index),
    ]
