import argparse
import asyncio
import subprocess
from fastapi import FastAPI

app = FastAPI()

# Async function to get the number of connected users on a given port
async def get_connected_users(port: int) -> int:
    proc = await asyncio.create_subprocess_shell(
        f"sudo netstat -tnp | grep ':{port}'",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    stdout, stderr = await proc.communicate()
    print(stdout.decode())
    if proc.returncode != 0:
        raise Exception(f"Error: {stderr.decode()}")
    return stdout.decode()

# FastAPI route to check the number of connected users on a port
@app.get("/get_usage")
async def check_port(v: int=None, sh: int=None):
    if v and sh:
        connected_users_v = await get_connected_users(v)
        connected_users_sh = await get_connected_users(sh)
        return {v: connected_users_v,
               sh: connected_users_sh}
    elif v and not sh:
        connected_users_v = await get_connected_users(v)
        return {v: connected_users_v}
    elif sh and not sh:
        connected_users_sh = await get_connected_users(sh)
        return {sh: connected_users_sh}
    else:
        return {'message': 'specify port'}

# Main function to handle command-line arguments
def main():
    parser = argparse.ArgumentParser(description="Port Checker Program")
    parser.add_argument('-v', '--vless', type=int, help='vless port')
    parser.add_argument('-sh', '--shadowsocks', type=int, help='shadowsocks port')

    args = parser.parse_args()

    # Set default port values if not provided
    vless_port = args.vless if args.vless is not None else 8443
    shadowsocks_port = args.shadowsocks if args.shadowsocks is not None else 1080

    print(f"Checking VLESS port {vless_port}...")
    vless_users = asyncio.run(get_connected_users(vless_port))
    print(f"Number of users connected to VLESS port {vless_port}: {vless_users}")

    print(f"Checking Shadowsocks port {shadowsocks_port}...")
    shadowsocks_users = asyncio.run(get_connected_users(shadowsocks_port))
    print(f"Number of users connected to Shadowsocks port {shadowsocks_port}: {shadowsocks_users}")

if __name__ == "__main__":
    main()
