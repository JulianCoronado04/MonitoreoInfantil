Local setup to see database data in the web app

What we added for you:
- `sql/local_init.sql` — T-SQL that creates database `monitoreo`, table `personas` and inserts a sample row.
- `apply_local_init.ps1` — PowerShell helper: tries to run `local_init.sql` using `sqlcmd` or `Invoke-Sqlcmd` (SqlServer module). If neither are available it instructs you to run the SQL in SSMS.
- `run_local.ps1` — helper to create a `.venv`, install requirements (if run with `-AutoInstall`) and run the Flask app using Trusted Connection.
- `templates/personas.html` and `/personas` route — a page that lists all rows from `personas`.

Steps to get the page to show DB data (minimal):

1) Verify connectivity (you already ran this):

   .\test_connection.ps1

   If it prints "Connection OK. SELECT 1 -> 1" you're ready.

2) Initialize the database and sample data:

   Preferred (if you have sqlcmd):

   .\apply_local_init.ps1 -Server 'localhost\\SQLEXPRESS01'

   If your instance requires SQL auth, add -SaPassword 'YourSAPassword'

   Alternative: open `sql/local_init.sql` in SQL Server Management Studio (SSMS), connect to `localhost\\SQLEXPRESS01` and run the script.

3) Run the web app locally using the venv auto installer (recommended):

   .\run_local.ps1 -PythonExe 'C:\Path\To\python311\python.exe' -AutoInstall

   If your `python` in PATH is already Python 3.11 and has pyodbc, you can omit `-PythonExe` and/or `-AutoInstall`.

4) Open the browser:

   http://127.0.0.1:5000

   - Go to "Herramienta" and search by id (try `1023344558`), or
   - Click "Ver personas" (or open /personas) to see the table listing all rows.

Notes & troubleshooting
- If `run_local.ps1 -AutoInstall` fails installing `pyodbc` because you use Python 3.13, use Docker (we included Dockerfile) or install Python 3.11 and run the script again using that executable.
- If `apply_local_init.ps1` can't find `sqlcmd` and you don't have the SqlServer PowerShell module, run `local_init.sql` manually in SSMS.
- Keep credentials (sa or any SQL user) secure — the helpers are for development only.
