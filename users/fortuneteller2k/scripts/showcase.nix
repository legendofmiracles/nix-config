''
  #!/bin/sh

  pfetch
  sleep 5;
  notify-desktop -u low "Urgency" "low" >/dev/null 2>&1
  notify-desktop -u normal "Urgency" "normal" >/dev/null 2>&1
  notify-desktop -u critical "Urgency" "critical" >/dev/null 2>&1
  sleep 5;
''
