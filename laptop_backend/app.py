import socket
from flask import Flask, jsonify, request
from zeroconf import IPVersion, ServiceInfo, Zeroconf
import pyautogui

app = Flask(__name__)
pyautogui.FAILSAFE = False

# Discover Network

def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("8.8.8.8",53))
        return s.getsockname()[0]
    except Exception:
        return "127.0.0.1"
    finally:
        s.close()

def start_mdns_broadcast(ip, port):
    info = ServiceInfo(
        type_="_zeroremote._tcp.local.",
        name="Laptop._zeroremote._tcp.local.",
        addresses=[socket.inet_aton(ip)],
        port=port,
        properties={'os': 'windows/mac/linux'}
    )
    zc = Zeroconf(ip_version=IPVersion.All)
    zc.register_service(info)
    print(f"[mDNS] Broadcasting 'ZeroRemote' on {ip}:{port}")
    return zc, info

# Endpoints

@app.route('/ping', methods=['GET'])
def ping():
    return jsonify({"status": "connected"}), 200
@app.route('/command', methods=['POST'])
def handle_command():
    data = request.get_json()
    if not data or 'action' not in data:
        return jsonify({"error": "No action provided"}), 400
    action = data['action']
    print(f'Received command: {action}')

    if action == 'volume_up':
        pyautogui.press('volumeup')
    elif action == 'volume_down':
        pyautogui.press('volumedown')
    elif action == 'space':
        pyautogui.press('space')
    return jsonify({"status": "success"}), 200


if __name__ == '__main__':
    port = 5000
    local_ip = get_local_ip()
    zc, info = start_mdns_broadcast(local_ip, port)
    try:
        print("Server is waiting for the Flutter app...")
        app.run(host='0.0.0.0', port=port, debug=False)
    finally:
        print("Shutting down broadcast...")
        zc.unregister_service(info)
        zc.close()
