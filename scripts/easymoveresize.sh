#!/usr/bin/env sh

cat <<EOF > $HOME/Library/LaunchAgents/org.dmarcotte.Easy-Move-Resize.LaunchAtLogin.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>org.dmarcotte.Easy-Move-Resize.LaunchAtLogin</string>
  <key>ProgramArguments</key>
  <array>
    <string>$HOME/Applications/Easy Move+Resize.app</string>
  </array>
  <key>RunAtLoad</key>
  <true/> <!-- run the program at login -->
  <key>KeepAlive</key>
  <true/> <!-- run the program again if it terminates -->
  <key>WorkingDirectory</key>
  <string>$HOME</string>
</dict>
</plist>
EOF
