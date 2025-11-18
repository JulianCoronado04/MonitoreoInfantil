# Monitoreo Infantil

## Project Description
"Monitoreo Infantil" is a web application developed using Flask that focuses on monitoring the growth and development of children. The application provides a user-friendly interface to visualize and manage data related to child development, integrating various data management processes.

## Project Structure
The project consists of the following files and directories:

```
monitoreo-infantil
├── app.py                # Main application file for the Flask project
├── static                # Directory for static files (CSS, JS)
│   ├── css
│   │   └── style.css     # CSS styles for the web application
│   └── js
│       └── script.js     # JavaScript code for interactive features
├── templates             # Directory for HTML templates
│   ├── index.html        # Main HTML template for the application
│   └── herramienta.html   # HTML template for the tool page
├── requirements.txt      # List of dependencies for the project
└── README.md             # Project documentation
```

## Setup Instructions
1. **Clone the repository**:
   ```
   git clone <repository-url>
   cd monitoreo-infantil
   ```

2. **Create a virtual environment** (optional but recommended):
   ```
   python -m venv venv
   source venv/bin/activate  # On Windows use `venv\Scripts\activate`
   ```

3. **Install the required dependencies**:
   ```
   pip install -r requirements.txt
   ```

4. **Run the application**:
   ```
   python app.py
   ```

5. **Access the application**:
   Open your web browser and go to `http://127.0.0.1:5000`.

## Features
- **Responsive Design**: The application is designed to be responsive and user-friendly across various devices.
- **Navigation Menu**: A fixed top navigation menu allows easy access to different sections of the application.
- **Interactive Elements**: Smooth scrolling and hover effects enhance user experience.

## Power BI integration
You can embed a Power BI report into the `Herramienta` page. The application reads the embed URL from the environment variable `POWERBI_EMBED_URL`. If not set, a default public embed URL provided by the project authors will be used.

To set the embed URL in Windows PowerShell (temporary for the session):
```powershell
$env:POWERBI_EMBED_URL = 'https://app.powerbi.com/view?r=<your-embed-token-or-id>'
```

Then run the app as usual:
```powershell
# Activate venv (Windows)
venv\Scripts\activate
python app.py
```

Notes:
- If your Power BI report is published with "Publish to web" (public), embedding via iframe is straightforward.
- For private reports or if you need role-level security, consider using the Power BI secure embed flow (requires Azure AD app registration and server-side token generation). If you want, I can help implement the secure embed flow.

## Authors
- Julian David Coronado
- Cristian Leonardo Moscoso
- Nicolas Gutierrez

## License
This project is licensed under the MIT License.

## Run with Docker (recommended for reproducible dev)

This repository includes a `Dockerfile` and `docker-compose.yml` that build the app in a Python 3.11 image and install the Microsoft ODBC driver so `pyodbc` works inside the container.

Quick start (PowerShell):

```powershell
# Build images and start the app + SQL Server (example uses docker-compose)
docker compose up --build

# Wait for SQL Server to initialize (the DB container can take ~20-30s on first run).

# Open http://localhost:5000 in your browser.
```

Notes:
- The included `docker-compose.yml` launches a SQL Server container (`mcr.microsoft.com/mssql/server`) with an example SA password `Your_strong!Passw0rd` and sets `MSSQL_CONN` in the `web` service so the Flask app can connect to the database.
- For local development change the SA password to something secure and update `docker-compose.yml` or set `MSSQL_CONN` explicitly as an environment variable.

Example `MSSQL_CONN` (used in the compose file):

```
DRIVER={ODBC Driver 18 for SQL Server};SERVER=db,1433;DATABASE=master;UID=sa;PWD=Your_strong!Passw0rd;TrustServerCertificate=yes
```

Creating a sample table and data (inside the running DB container):

```powershell
# Run an interactive sqlcmd inside the DB container (after db is healthy)
docker exec -it mi_mssql /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "Your_strong!Passw0rd"

-- then in sqlcmd run:
CREATE DATABASE monitoreo;
GO
USE monitoreo;
GO
CREATE TABLE personas (
   id_number NVARCHAR(50) PRIMARY KEY,
   nombre NVARCHAR(100),
   apellido NVARCHAR(100),
   fecha_nacimiento DATE
);
GO
INSERT INTO personas (id_number, nombre, apellido, fecha_nacimiento) VALUES ('1023344558','Julian','Coronado','2010-05-12');
GO
EXIT
```

Security / production notes:
- The compose file and Docker setup here are for local development and demos. Do not use the example SA password in production.
- For production, provision SQL Server separately, secure credentials with a secrets manager or environment variables, and run the Flask app behind a proper web server + TLS.

If you want, puedo construir y probar la imagen Docker aquí (si me indicas que quieres que lo intente), o puedo ajustar el `docker-compose.yml` para apuntar a una base de datos existente.