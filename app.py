from fastapi import FastAPI
from fastapi.responses import HTMLResponse
import requests

app = FastAPI()

URL = "https://jsonplaceholder.typicode.com/users"

@app.get("/", response_class=HTMLResponse)
def mostrar_usuarios():
    response = requests.get(URL)
    usuarios = response.json()

    filas = ""
    for u in usuarios:
        filas += f"""
        <tr>
            <td>{u['id']}</td>
            <td>{u['name']}</td>
            <td>{u['username']}</td>
            <td>{u['email']}</td>
            <td>{u['address']['city']}</td>
        </tr>
        """

    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>Usuarios</title>
        <style>
            body {{ font-family: Arial, sans-serif; padding: 20px; }}
            table {{ border-collapse: collapse; width: 100%; }}
            th, td {{ border: 1px solid #ccc; padding: 8px; text-align: left; }}
            th {{ background-color: #f4f4f4; }}
            tr:nth-child(even) {{ background-color: #fafafa; }}
        </style>
    </head>
    <body>
        <h1>Lista de Usuarios</h1>
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Nombre</th>
                    <th>Usuario</th>
                    <th>Email</th>
                    <th>Ciudad</th>
                </tr>
            </thead>
            <tbody>
                {filas}
            </tbody>
        </table>
    </body>
    </html>
    """

    return html
