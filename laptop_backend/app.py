import socket
from flask import Flask, jsonify, request
from zeroconf import IPVersion, ServiceInfo, Zeroconf

app = Flask(__name__)

# Discover Network

def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("8.8.8.8", 53))
        return s.getsockname()[0]
    except Exception:
        return "127.0.0.1"
    finally:
        s.close()

import uuid

def start_mdns_broadcast(ip, port):
    uid = uuid.uuid4().hex[:4]
    info = ServiceInfo(
        type_="_zeroremote._tcp.local.",
        name=f"Laptop-{uid}._zeroremote._tcp.local.",
        server="Laptop.local.",
        addresses=[socket.inet_aton(ip)],
        port=port,
        properties={'os': 'windows'}
    )
    # V4Only ensures clean packet broadcasting to Android devices
    zc = Zeroconf(ip_version=IPVersion.V4Only)
    zc.register_service(info)
    print(f"[mDNS] Broadcasting 'ZeroRemote' on {ip}:{port}")
    return zc, info

# Endpoints

@app.route('/ping', methods=['GET'])
def ping():
    return jsonify({"status": "connected"}), 200

import ctypes
import pyautogui
pyautogui.FAILSAFE = False

# Virtual-Key codes
VK_VOLUME_MUTE = 0xAD
VK_VOLUME_DOWN = 0xAE
VK_VOLUME_UP = 0xAF
VK_MEDIA_NEXT_TRACK = 0xB0
VK_MEDIA_PREV_TRACK = 0xB1
VK_MEDIA_STOP = 0xB2
VK_MEDIA_PLAY_PAUSE = 0xB3
VK_SPACE = 0x20

def press_key(hexKeyCode):
    KEYEVENTF_EXTENDEDKEY = 0x0001
    KEYEVENTF_KEYUP = 0x0002
    ctypes.windll.user32.keybd_event(hexKeyCode, 0, KEYEVENTF_EXTENDEDKEY, 0) # Press
    ctypes.windll.user32.keybd_event(hexKeyCode, 0, KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP, 0) # Release

@app.route('/command', methods=['POST'])
def handle_command():
    data = request.get_json()
    if not data or 'action' not in data:
        return jsonify({"error": "No action provided"}), 400
    action = data['action']

    if action == 'volume_up':
        press_key(VK_VOLUME_UP)
    elif action == 'volume_down':
        press_key(VK_VOLUME_DOWN)
    elif action == 'volume_mute':
        press_key(VK_VOLUME_MUTE)
    elif action == 'play_pause':
        press_key(VK_MEDIA_PLAY_PAUSE)
    elif action == 'prev_track':
        press_key(VK_MEDIA_PREV_TRACK)
    elif action == 'next_track':
        press_key(VK_MEDIA_NEXT_TRACK)
    elif action == 'sleep':
        # Put computer to sleep (suspend state)
        ctypes.windll.powrprof.SetSuspendState(0, 1, 0)
    elif action == 'mouse_move':
        dx = data.get('dx', 0)
        dy = data.get('dy', 0)
        pyautogui.moveRel(dx, dy)
    elif action == 'mouse_click':
        button = data.get('button', 'left')
        pyautogui.click(button=button)
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