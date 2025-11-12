from flask import Flask, render_template, request
import os

try:
    import pyodbc
except Exception:
    pyodbc = None

app = Flask(__name__)


def query_person_by_id(id_number: str):
    """Query SQL Server for a person by id_number.

    Expects a full ODBC connection string in the environment variable `MSSQL_CONN`.
    Example: "DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost;DATABASE=mydb;UID=user;PWD=pass"

    Returns (person_dict_or_None, error_message_or_None).
    """
    # Priority 1: full connection string via MSSQL_CONN
    conn_str = os.environ.get('MSSQL_CONN')

    # If not provided, build it from components. This allows two common dev modes:
    #  - Local Windows Integrated Auth (Trusted Connection) using instance name like localhost\SQLEXPRESS01
    #  - SQL Authentication (UID/PWD) for remote/containers
    if not conn_str:
        driver = os.environ.get('MSSQL_DRIVER', 'ODBC Driver 18 for SQL Server')
        server = os.environ.get('MSSQL_SERVER', 'localhost')
        port = os.environ.get('MSSQL_PORT')
        database = os.environ.get('MSSQL_DATABASE', 'monitoreo')
        user = os.environ.get('MSSQL_USER')
        password = os.environ.get('MSSQL_PASSWORD')
        trust = os.environ.get('MSSQL_TRUST', 'yes')

        # If a port is provided, use SERVER=host,port (TCP). If server contains a backslash (instance name), keep as-is.
        if port and '\\' not in server:
            server_part = f"{server},{port}"
        else:
            server_part = server

        # Build connection string depending on whether credentials exist
        if user and password:
            conn_str = (
                f"DRIVER={{{driver}}};SERVER={server_part};DATABASE={database};"
                f"UID={user};PWD={password};TrustServerCertificate={trust}"
            )
        else:
            # Use integrated Windows authentication (Trusted Connection)
            conn_str = (
                f"DRIVER={{{driver}}};SERVER={server_part};DATABASE={database};"
                "Trusted_Connection=yes;TrustServerCertificate=yes"
            )

    if pyodbc is None:
        return None, 'pyodbc is not installed or failed to import. Install pyodbc or run the app in the Docker image provided.'

    try:
        # Use a timeout and context manager for safety
        with pyodbc.connect(conn_str, timeout=5) as conn:
            cur = conn.cursor()
            # Adjust the table/column names to match your database schema.
            cur.execute("SELECT id_number, nombre, apellido, fecha_nacimiento FROM dbo.personas WHERE id_number = ?", id_number)
            row = cur.fetchone()
            if not row:
                return None, None
            person = {
                'id_number': row[0],
                'nombre': row[1],
                'apellido': row[2],
                'fecha_nacimiento': str(row[3]) if row[3] is not None else None,
            }
            return person, None
    except Exception as e:
        return None, str(e)


def query_all_persons():
    """Return list of all persons or (None, error_message)."""
    conn_str = os.environ.get('MSSQL_CONN')
    if not conn_str:
        driver = os.environ.get('MSSQL_DRIVER', 'ODBC Driver 18 for SQL Server')
        server = os.environ.get('MSSQL_SERVER', 'localhost')
        port = os.environ.get('MSSQL_PORT')
        database = os.environ.get('MSSQL_DATABASE', 'monitoreo')
        user = os.environ.get('MSSQL_USER')
        password = os.environ.get('MSSQL_PASSWORD')

        if port and '\\' not in server:
            server_part = f"{server},{port}"
        else:
            server_part = server

        if user and password:
            conn_str = (
                f"DRIVER={{{driver}}};SERVER={server_part};DATABASE={database};"
                f"UID={user};PWD={password};TrustServerCertificate=yes"
            )
        else:
            conn_str = (
                f"DRIVER={{{driver}}};SERVER={server_part};DATABASE={database};"
                "Trusted_Connection=yes;TrustServerCertificate=yes"
            )

    if pyodbc is None:
        return None, 'pyodbc is not installed or failed to import.'

    try:
        with pyodbc.connect(conn_str, timeout=5) as conn:
            cur = conn.cursor()
            cur.execute("SELECT id_number, nombre, apellido, fecha_nacimiento FROM dbo.personas ORDER BY id_number")
            rows = cur.fetchall()
            persons = []
            for r in rows:
                persons.append({
                    'id_number': r[0],
                    'nombre': r[1],
                    'apellido': r[2],
                    'fecha_nacimiento': str(r[3]) if r[3] is not None else None,
                })
            return persons, None
    except Exception as e:
        return None, str(e)


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/herramienta', methods=['GET', 'POST'])
def herramienta():
    id_number = None
    person = None
    db_error = None

    if request.method == 'POST':
        id_number = request.form.get('id_number', '').strip()
        if id_number:
            person, db_error = query_person_by_id(id_number)

    return render_template('herramienta.html', id_number=id_number, person=person, db_error=db_error)


@app.route('/personas')
def personas():
    persons, db_error = query_all_persons()
    return render_template('personas.html', persons=persons, db_error=db_error)


if __name__ == '__main__':
    app.run(debug=True)