#!/bin/bash
cat << "EOF"

███████╗ █████╗ ███████╗██╗   ██╗    ██╗  ██╗██╗██╗     ██╗     ███████╗██╗    ██╗██╗████████╗ ██████╗██╗  ██╗
██╔════╝██╔══██╗██╔════╝╚██╗ ██╔╝    ██║ ██╔╝██║██║     ██║     ██╔════╝██║    ██║██║╚══██╔══╝██╔════╝██║  ██║
█████╗  ███████║███████╗ ╚████╔╝     █████╔╝ ██║██║     ██║     ███████╗██║ █╗ ██║██║   ██║   ██║     ███████║
██╔══╝  ██╔══██║╚════██║  ╚██╔╝      ██╔═██╗ ██║██║     ██║     ╚════██║██║███╗██║██║   ██║   ██║     ██╔══██║
███████╗██║  ██║███████║   ██║       ██║  ██╗██║███████╗███████╗███████║╚███╔███╔╝██║   ██║   ╚██████╗██║  ██║
╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝       ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚══════╝ ╚══╝╚══╝ ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝
                                                                                                              
EOF

echo "🏴‍☠️  easy-killswitch: A VPN Kill Switch for macOS using pf 🏴‍☠️"
echo "🔒 Your traffic is safe. If your VPN disconnects, all traffic is blocked."

RULES_FILE="/etc/pf-killswitch.conf"
CUSTOM_IFACE=""
CUSTOM_SERVER_IP=""

show_help() {
    echo "Usage: killswitch [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --disable         Disable the kill switch"
    echo "  --help            Show this help message"
    exit 0
}

disable_killswitch() {
    read -p "❗️ Disabling the Kill Switch will expose your traffic to the internet if the VPN connection drops. Are you sure you want to disable it? (y/n): " -n 1 -r
    echo "❌ Disabling Kill Switch and removing specific pf rules..."
    sudo pfctl -d 2>/dev/null
    sudo rm -f "$RULES_FILE"
    echo "🔓 Kill Switch disabled. Your traffic is no longer protected if the VPN connection drops."
    exit 0
}

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --disable)
            disable_killswitch
            ;;
        --help)
            show_help
            ;;
        *)
            echo "❌ Unknown option: $1"
            show_help
            ;;
    esac
    shift
done

# - Detect the active VPN name -
VPN_NAME=$(scutil --nc list | awk -F'"' '/\(Connected\)/ {print $2}')
if [[ -z "$VPN_NAME" ]]; then
    echo "❌ No active VPN connection detected. Make sure you are connected to a VPN."
    exit 1
fi

echo "✅ Active VPN: $VPN_NAME"

# - Get the VPN interface name - 
WG_IFACE=$(scutil --nc status "$VPN_NAME" | awk -F' ' '/InterfaceName/ {print $3}')
if [[ -z "$WG_IFACE" ]]; then
    echo "❌ Unable to determine VPN interface. Check your connection."
    exit 1
fi

# - Get the remote VPN server IP -
REMOTE_ADDR=$(scutil --nc show "$VPN_NAME" | awk '/RemoteAddress/ {print $3}' | awk -F':' '{print $1}')
if [[ -z "$REMOTE_ADDR" ]]; then
    echo "❌ Unable to determine remote VPN server IP. Check your VPN configuration."
    exit 1
fi

# - Detect ALL physical interfaces (excluding VPNs) -
PHYSICAL_IFACES=$(netstat -rn -f inet | awk '/default/ {print $NF}' | grep -v "$WG_IFACE" | sort -u | tr '\n' ' ')

if [[ -z "$PHYSICAL_IFACES" ]]; then
    echo "❌ Unable to detect physical network interfaces. Check your connection."
    exit 1
fi

echo "✅ VPN Interface: $WG_IFACE"
echo "✅ Physical Interfaces: $PHYSICAL_IFACES"
echo "✅ VPN Server IP: $REMOTE_ADDR"
echo "🚀 Activating Kill Switch..."

sudo pfctl -E 2>/dev/null

echo "Creating pf rules file..."
{
    echo "block drop out on { $PHYSICAL_IFACES } all"
    echo "pass out quick on $WG_IFACE all keep state"
    echo "pass out quick on { $PHYSICAL_IFACES } to $REMOTE_ADDR keep state"
} | sudo tee "$RULES_FILE" > /dev/null

sudo pfctl -f "$RULES_FILE" 2>/dev/null

echo "🔒 Kill Switch activated, your traffic is safe. If the VPN disconnects, all traffic will be blocked."
echo "To disable it, run: killswitch --disable"
