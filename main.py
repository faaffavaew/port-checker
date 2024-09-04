import asyncio
import subprocess
import os

import uvicorn
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, status

load_dotenv()

app = FastAPI(docs_url=None, redoc_url=None)

SECRET_KEY = str(os.getenv("SECRET_KEY"))
SS_PORT = int(os.getenv("SS_PORT"))
VLESS_PORT = int(os.getenv("VLESS_PORT"))


async def get_connected_users(port: int) -> int:
    command = f"sudo netstat -tnp | grep ':{port}'"
    proc = await asyncio.create_subprocess_shell(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    stdout, stderr = await proc.communicate()

    if proc.returncode != 0:
        print(f"No connections found on port {port}.")
        return 0

    # Decode the output and split it into lines
    lines = stdout.decode().splitlines()

    # If no lines are found, log that no connections were found
    if not lines:
        print(f"No connections found on port {port}.")
        return 0

    # Extract unique IP addresses
    ip_addresses = set()
    for line in lines:
        # Split the line and extract the remote IP address
        parts = line.split()
        if len(parts) > 4:
            remote_ip = parts[4].split(':')[0]
            ip_addresses.add(remote_ip)

    return len(ip_addresses)


@app.get("/get_usage/{key}")
async def check_port(key: str):
    if not key or key != SECRET_KEY:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Invalid secret key.")
    try:
        response = {}

        if VLESS_PORT:
            connected_users_v = await get_connected_users(VLESS_PORT)
            response[str(VLESS_PORT)] = connected_users_v

        if SS_PORT:
            connected_users_sh = await get_connected_users(SS_PORT)
            response[str(SS_PORT)] = connected_users_sh

        if not response:
            return {'message': 'Specify valid ports.'}

        return response
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=54172, reload=True)