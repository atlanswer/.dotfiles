#!/bin/zsh

iface=$(ip route | awk '/default/ {print $5; exit}')

if [[ -z "$iface" ]]; then
  echo '{"text": "󰤮", "tooltip": "Disconnected"}'
  exit 0
fi

rx_prev=$(cat /tmp/waybar_rx 2>/dev/null || echo 0)
tx_prev=$(cat /tmp/waybar_tx 2>/dev/null || echo 0)

rx_now=$(cat /sys/class/net/"$iface"/statistics/rx_bytes 2>/dev/null || echo 0)
tx_now=$(cat /sys/class/net/"$iface"/statistics/tx_bytes 2>/dev/null || echo 0)

echo "$rx_now" > /tmp/waybar_rx
echo "$tx_now" > /tmp/waybar_tx

# Skip first run (no previous data)
if [[ "$rx_prev" -eq 0 ]]; then
  echo '{"text": "~", "tooltip": "Calculating..."}'
  exit 0
fi

rx_rate=$(( (rx_now - rx_prev) / 3 ))
tx_rate=$(( (tx_now - tx_prev) / 3 ))

icon="󰈀"

# Format speeds (only show if > 1MB/s)
threshold=$((1024 * 1024))
text="$icon"

if (( rx_rate > threshold )); then
  rx_mb=$(awk "BEGIN {printf \"%.1f\", $rx_rate / 1048576}")
  text="$icon  ${rx_mb} M/s"
fi

if (( tx_rate > threshold )); then
  tx_mb=$(awk "BEGIN {printf \"%.1f\", $tx_rate / 1048576}")
  text="$text  ${tx_mb} M/s"
fi

# Tooltip
# essid=$(iwgetid -r 2>/dev/null || echo "Ethernet")
essid="Ethernet"
ipaddr=$(ip -4 addr show $iface | awk '/inet/ {print $2}')
ipaddr=${ipaddr:-N/A}

rx_fmt=$(numfmt --to=iec --suffix=/s "$rx_rate" 2>/dev/null || echo "0/s")
tx_fmt=$(numfmt --to=iec --suffix=/s "$tx_rate" 2>/dev/null || echo "0/s")

tooltip="$essid\n$ipaddr\n $rx_fmt  $tx_fmt"

printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$tooltip"
