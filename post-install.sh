#!/bin/bash
set -e

MARKER="/var/lib/flatpak-bootstrap.done"

if [ -f "$MARKER" ]; then
    exit 0
fi

flatpak remote-delete fedora || true
sleep 2
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sleep 2

apps=(
be.alexandervanhee.gradia
ca.desrt.dconf-editor
com.brave.Browser
com.dec05eba.gpu_screen_recorder
com.discordapp.Discord
com.github.tchx84.Flatseal
com.mattjakeman.ExtensionManager
com.spotify.Client
com.thincast.client
im.riot.Riot
io.mpv.Mpv
net.nokyan.Resources
org.fedoraproject.MediaWriter
org.gnome.Boxes
org.gnome.Calculator
org.gnome.Evince
org.gnome.Loupe
org.gnome.Showtime
org.gnome.TextEditor
org.localsend.localsend_app
org.mozilla.firefox
org.remmina.Remmina
org.telegram.desktop
org.upscayl.Upscayl
page.codeberg.JakobDev.jdReplace
page.codeberg.libre_menu_editor.LibreMenuEditor
)

installed=$(flatpak list --app --columns=application)

missing=()

for app in "${apps[@]}"; do
    if ! grep -qx "$app" <<< "$installed"; then
        missing+=("$app")
    fi
done

if [ "${#missing[@]}" -eq 0 ]; then
    touch "$MARKER"
    exit 0
fi

echo "Instalando Flatpaks ausentes..."
flatpak install -y flathub "${missing[@]}"

touch "$MARKER"
