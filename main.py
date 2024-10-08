import asyncio
import os
import uvicorn
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, status

# Load environment variables from .env file
load_dotenv()

# Initialize FastAPI app
app = FastAPI(docs_url=None, redoc_url=None)

# Read environment variables
SECRET_KEY = str(os.getenv("SECRET_KEY"))
SS_PORT = int(os.getenv("SS_PORT"))
VLESS_PORT = int(os.getenv("VLESS_PORT"))


async def get_connected_users(port: int) -> int:
    """
    Get the number of unique connected users on a specific port using 'ss' command.
    :param port: The port number to check.
    :return: Number of unique IP addresses connected.
    """
    command = f"ss -tan | grep ':{port} '"
    proc = await asyncio.create_subprocess_shell(
        command,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE
    )
    stdout, stderr = await proc.communicate()

    if proc.returncode != 0:
        print(f"Error or no connections found on port {port}: {stderr.decode().strip()}")
        return 0

    lines = stdout.decode().splitlines()

    if not lines:
        print(f"No connections found on port {port}.")
        return 0

    ip_addresses = set()
    for line in lines:
        parts = line.split()
        if len(parts) >= 1 and parts[0] == "ESTAB":
            # Extract remote IP:port (it's the last column)
            remote_ip_port = parts[-1]

            # IPv6 addresses come enclosed in square brackets; IPv4 do not
            if remote_ip_port.startswith('['):  # IPv6 address
                remote_ip = remote_ip_port.split(']:')[0][1:]  # Remove '[' and split by ']:'
            else:  # IPv4 address
                remote_ip = remote_ip_port.split(':')[0]  # Extract IP part before the colon

            ip_addresses.add(remote_ip)

    print("Connected ESTAB IPs:", ip_addresses)
    return len(ip_addresses)


@app.get("/get_usage/{key}")
async def check_port(key: str):
    """
    API endpoint to check the number of connected users on specified ports.
    :param key: Security key for authorization.
    :return: Dictionary with port numbers and connected users count.
    """
    if not key or key != SECRET_KEY:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Invalid secret key.")
    try:
        response = {}

        # Check VLESS port connections
        if VLESS_PORT:
            connected_users_v = await get_connected_users(VLESS_PORT)
            response[str(VLESS_PORT)] = connected_users_v

        # Check Shadowsocks port connections
        if SS_PORT:
            connected_users_sh = await get_connected_users(SS_PORT)
            response[str(SS_PORT)] = connected_users_sh

        if not response:
            return {'message': 'No valid ports provided for checking.'}

        return response
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=54172, reload=True)
