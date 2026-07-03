#!/usr/bin/env bash
# Setup completo do dd-claudeusage:
#   - venv + dependências
#   - app da barra de menu (.app em ~/Applications, o Spotlight acha pelo nome)
#   - LaunchAgent pra abrir sozinho no login
set -e
cd "$(dirname "$0")"
SRC="$(pwd)"

echo "→ venv + dependências"
python3 -m venv .venv
.venv/bin/pip install -q -r requirements.txt

echo "→ app da barra de menu em ~/Applications"
APP="$HOME/Applications/dd-claudeusage.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp assets/appicon.icns "$APP/Contents/Resources/appicon.icns"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>dd-claudeusage</string>
  <key>CFBundleDisplayName</key><string>dd-claudeusage</string>
  <key>CFBundleIdentifier</key><string>com.ddclaudeusage.app</string>
  <key>CFBundleVersion</key><string>1.0</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleExecutable</key><string>dd-claudeusage</string>
  <key>CFBundleIconFile</key><string>appicon</string>
  <key>LSUIElement</key><true/>
</dict></plist>
PLIST
cat > "$APP/Contents/MacOS/dd-claudeusage" <<LAUNCH
#!/bin/sh
# lança desanexado e sai na hora, senão o LaunchServices trava o bundle e o 2º open não abre
/usr/bin/pgrep -f '[p]ython.*dd_claudeusage\.py' >/dev/null 2>&1 && exit 0
nohup "$SRC/.venv/bin/python" "$SRC/dd_claudeusage.py" >/dev/null 2>&1 &
exit 0
LAUNCH
chmod +x "$APP/Contents/MacOS/dd-claudeusage"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP" 2>/dev/null || true

echo "→ LaunchAgent (abrir no login)"
PL="$HOME/Library/LaunchAgents/com.dd-claudeusage.plist"
cat > "$PL" <<AGENT
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>com.dd-claudeusage</string>
  <key>ProgramArguments</key>
  <array><string>$SRC/.venv/bin/python</string><string>$SRC/dd_claudeusage.py</string></array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><dict><key>SuccessfulExit</key><false/></dict>
  <key>StandardOutPath</key><string>$SRC/app.log</string>
  <key>StandardErrorPath</key><string>$SRC/app.log</string>
</dict></plist>
AGENT
launchctl unload "$PL" 2>/dev/null || true
launchctl load -w "$PL"

if [ ! -f .token ]; then
  echo
  echo "→ (recomendado) token pro % OFICIAL do plano:"
  echo "     claude setup-token          # gera sk-ant-oat01-..."
  echo "     ...cole a saída em:  $SRC/.token"
  echo "   sem token, roda no modo ccusage (custo estimado em \$)."
fi
echo
echo "✓ instalado e rodando. Procure 'dd-claudeusage' no Spotlight (Cmd+Espaço)."
