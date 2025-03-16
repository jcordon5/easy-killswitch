
# Easy Kill Switch
      
`easy-killswitch` is a simple yet effective kill switch for VPN users, ensuring that no traffic leaks if your VPN connection drops. It currently supports **macOS** using `pf` and will be expanded to support **Linux (iptables/nftables)** and **Windows (Firewall rules)**.

## 🔥 Why use easy-killswitch?
- **Prevents traffic leaks** if the VPN disconnects.
- **Does not overwrite system rules** – only manages its own.
- **Easy to enable/disable** with a single command.
- **Supports multiple VPN protocols** (WireGuard, OpenVPN, and more in future versions).
- **Open-source and extensible**.

## 📌 **Index**
- [Supported Systems](#🚀-supported-systems)
- [Installation](#🛠-installation)
  - [macOS](#macos)
- [Usage](#⚡-usage)
- [How does it work?](#🛡-how-does-it-work)
- [Contributing](#📢-contributing)
- [License](#📜-license)
---

## 🚀 Supported Systems 
| OS      | VPN Protocols | Status |
|---------|--------------|--------|
| macOS   | WireGuard, Manually Configured, OpenVPN* | ✅ Fully functional |
| Linux   | WireGuard, OpenVPN | 🔄 Work in progress |
| Windows | WireGuard, OpenVPN | 🔄 Work in progress |

---

## 🛠 Installation

### macOS
1. Clone the repository:
   ```bash
   git clone https://github.com/jcordon5/easy-killswitch.git
   cd easy-killswitch
   ```
2. Run the installer:
   ```bash
   sudo bash install.sh
   ```
3. Follow the instructions to add `killswitch` as a global command.


#### 🔄 **Supported VPNs on macOS**
`easy-killswitch` works with:

✅ **WireGuard** (imported via the official WireGuard app)  
✅ **Any VPN manually added in** **System Settings > Network > VPN**  
❌ **OpenVPN profiles do not appear in `scutil` and need a workaround** (see below).  

⚠️ **Using OpenVPN with easy-killswitch on macOS**

OpenVPN profiles imported through **Tunnelblick, Viscosity, or OpenVPN Connect** do not appear in `scutil --nc list`, meaning they cannot be detected automatically.  

**Workaround: Convert OpenVPN to IKEv2**
If your VPN provider supports **IKEv2**, you can manually add it to macOS so it works with `easy-killswitch`.  

1️⃣ **Extract the necessary information from your `.ovpn` profile**  
   Open the `.ovpn` file in a text editor and look for:
   - `remote your-vpn-server.com 1194 udp` (server address)
   - `auth-user-pass` (username and password)
   - Certificate details (`ca`, `cert`, `key`) if required.

2️⃣ **Go to macOS System Settings > Network**  
   - Click **Add VPN Configuration**.  
   - Choose **IKEv2**.  
   - Enter your VPN **server address**, username, and password.  
   - If required, upload your **certificate**.  

3️⃣ **Now `scutil --nc list` will detect your VPN!** 

   Run:

   ```bash
   scutil --nc list
   scutil --nc status "YourVPNName"
   ``` 

---

## ⚡ Usage
After installation, you can use the `killswitch` command.

| Command                        | Description |
|--------------------------------|-------------|
| `killswitch`                   | Activate the kill switch |
| `killswitch --disable`         | Disable the kill switch |
| `killswitch --help`            | Show available options |

Once activated, **all internet traffic will be blocked if the VPN connection drops**. To disable the kill switch, use:

```bash
killswitch --disable
```

---

## 🛡 How does it work?
- Detects the active **VPN interface**.
- Identifies the **physical network interface** used for internet traffic.
- Blocks all outgoing traffic on the physical interface **except to the VPN server**.
- If the VPN disconnects, **all traffic is blocked** until it reconnects.

---

## 📢 Contributing
We welcome contributions! If you want to improve `easy-killswitch`, feel free to:
- Submit issues or feature requests.
- Fork the repo and submit pull requests.
- Help us implement **Linux & Windows support**.

---

## 📜 License
This project is licensed under the **MIT License**, so feel free to modify and use it.

**Stay secure!** 🏴‍☠️
