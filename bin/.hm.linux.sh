__hm_linux_list_config(){
    local callback_func="${1:-echo}"
    local root="$HM_TOOLS_TRACK_DIR"

    # Define common KDE/Debian/Neon config directories
    local CONFIG_DIRS=(
        "$root/.config"
        "$root/.local/share"
        "$root/.kde/share/config" # Older KDE configs
        "$root/.fonts"
        "$root/.icons"
        "$root/.themes"
        "$root/.gtkrc-2.0"
        "$root/.bashrc"
        "$root/.zshrc"
        "$root/.profile"
        "$root/.xinitrc"
        "$root/.Xresources"
        "$root/.gnupg"
        "$root/.ssh"
        "$root/.gitconfig"
    )

    # Define common file extensions for config files
    local CONFIG_EXTS=(
        "conf" "rc" "ini" "json" "xml" "yaml" "yml" "desktop"
        "keys" "shortcuts" "kdeglobals" "colors" "kateschemarc" "profile"
        "service" # for systemd user services
    )

    # Define a list of directories/files to explicitly exclude (common caches, temporary files, etc.)
    local EXCLUDE_PATTERNS=(
        ".cache"
        ".thunderbird"
        ".mozilla/firefox/*/cache"
        ".gnome/apps" # Older GNOME cruft
        "plasma-notifier" # Plasma notification database
        "pulse" # Pulseaudio client info
        "dconf" # dconf database
        "Trolltech.conf" # Qt config for some apps
        "VirtualBox"
    # "discord" # Discord config
    # "Signal" # Signal config
        "chromium" # Chromium user data
        "google-chrome" # Google Chrome user data
        "vlc" # VLC cache
        "mimeapps.list" # Mime associations (often auto-generated)
        "user-places.xbel" # Browser bookmarks (often auto-generated)
        "recently-used.xbel" # Recently used files (often auto-generated)
        "kscreenlockerrc" # KScreenlocker settings (often system-specific)
        "krunnerrc" # KRunner settings (often system-specific)
        "kxkbrc" # Keyboard layout (often system-specific)
        "plasma-localerc" # Locale settings (often system-specific)
        "plasma-org.kde.plasma.desktop-appletsrc" # Plasma layout (can be very dynamic)
        "session" # Session related files
        "subversion" # Subversion caches
        "gvfs" # GVFS metadata
        "ibus" # IBus caches
        "npm" # Node.js package manager cache
        "pki" # Public Key Infrastructure certificates
        "gem" # RubyGems cache
        "go" # Go related files
        "cargo" # Rust Cargo cache
        "vscode" # VSCode cache/extensions
        "Code" # VSCode data
        "zoom" # Zoom app data
        "teams" # Microsoft Teams app data
        "skype" # Skype app data
        "flatpak" # Flatpak data
        "snap" # Snap data
        "containers" # Podman/Docker containers
        "compose-cache" # Docker compose cache
        "Trash"
        ".Trash"
        "textmate" # intellij plugin
        "android"
        "kde-builder"
        "META-INF"
        "node_modules"
    )

    for dir in "${CONFIG_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            find "$dir" -type f -print0 | while IFS= read -r -d $'\0' file; do
                filename=$(basename "$file")
                dirname=$(dirname "$file")
                
                # Check for file extension
                found_ext=false
                for ext in "${CONFIG_EXTS[@]}"; do
                    if [[ "$filename" == *".$ext" ]]; then
                        found_ext=true
                        break
                    fi
                done

                # Check for specific filenames without extensions that are commonly config files
                if ! $found_ext; then
                    case "$filename" in
                        "environment"|"hosts"|"resolv.conf"|"nsswitch.conf"|"fstab"|"mtab"|"profile"|"inputrc"|"bash.bashrc"|"bash_logout"|"sudoers")
                            found_ext=true # Treat these as config files
                            ;;
                    esac
                fi
                
                if $found_ext; then
                    # Check for explicit exclusions
                    exclude=false
                    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
                        if [[ "$file" == *"$pattern"* ]]; then
                            exclude=true
                            break
                        fi
                    done
                    
                    if ! $exclude; then
                        "$callback_func" "$file"
                    fi
                fi
            done
        fi
    done

}