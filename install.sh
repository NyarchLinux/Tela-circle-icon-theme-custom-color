#!/usr/bin/env bash

if [ ${UID} -eq 0 ]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="${HOME}/.local/share/icons"
fi

readonly SRC_DIR=$(cd $(dirname $0) && pwd)

readonly BRIGHT_VARIANTS=("" "light" "dark")

if command -v lsb_release &> /dev/null; then
  Distributor_ID=$(lsb_release -i)
  if [[ "${Distributor_ID}" == "Distributor ID:    elementary" || "${Distributor_ID}" == "Distributor ID:    Elementary" ]]; then
    ICON_VERSION="elementary"
  else
    ICON_VERSION="normal"
  fi
  echo -e "Install $ICON_VERSION version! ..."
else
  ICON_VERSION="normal"
fi

usage() {
  cat << EOF
Usage: $0 [OPTION] | [HEX_COLOR]...

OPTIONS:
  -a"#hex-color" 	installs the themes with the given hex value, this will happend the hex to the begining of the folder name don't forget the quotations marks nor the #
  -c                       Install circular folder version
  -d DIR                   Specify theme destination directory (Default: $HOME/.local/share/icons)
  -n NAME                  Specify theme name (Default: Tela-circle)
  -h                       Show this help

EOF
}

install_theme() {
  local -r hex_color="$1"

  if [[ "${circle}" == 'true' ]]; then
    local -r folderstyle="-circle"
  else
    local -r folderstyle="-normal"
  fi

  local -r brightprefix="${2:+-$2}"

  local -r THEME_NAME="${hex_color}-${NAME}${brightprefix}"
  local -r THEME_DIR="${DEST_DIR}/${THEME_NAME}"

  if [ -d "${THEME_DIR}" ]; then
    rm -r "${THEME_DIR}"
  fi

  echo "Installing '${THEME_NAME}'..."

  install -d "${THEME_DIR}"

  install -m644 "${SRC_DIR}/src/index.theme"                                     "${THEME_DIR}"

  # Update the name in index.theme
  sed -i "s/%NAME%/${THEME_NAME//-/ }/g"                                         "${THEME_DIR}/index.theme"

  if [ -z "${brightprefix}" ]; then
    cp -r "${SRC_DIR}"/src/{16,22,24,32,symbolic}                                "${THEME_DIR}"
    mkdir -p                                                                     "${THEME_DIR}/scalable"
    cp -r "${SRC_DIR}"/src/scalable/{apps,devices,mimetypes}                     "${THEME_DIR}/scalable"
    cp -r "${SRC_DIR}"/src/scalable/places${folderstyle}                         "${THEME_DIR}/scalable/places"

    sed -i "s/#5294e2/${hex_color}/g" "${THEME_DIR}/scalable/apps/"*.svg "${THEME_DIR}/scalable/places/"default-*.svg "${THEME_DIR}/16/places/"folder*.svg
    sed -i "/\ColorScheme-Highlight/s/currentColor/${hex_color}/" "${THEME_DIR}/scalable/places/"default-*.svg "${THEME_DIR}/16/places/"folder*.svg
    sed -i "/\ColorScheme-Background/s/currentColor/#ffffff/" "${THEME_DIR}/scalable/places/"default-*.svg

    cp -r "${SRC_DIR}"/links/{16,22,24,32,scalable,symbolic}                     "${THEME_DIR}"

    if [[ "${ICON_VERSION}" == 'elementary' || "$DESKTOP_SESSION" == 'xfce' ]]; then
      cp -r "${SRC_DIR}/elementary/"*                                            "${THEME_DIR}"
    fi
  fi

  if [[ "${brightprefix}" == '-light' ]]; then
    local -r STD_THEME_DIR="${THEME_DIR%-light}"

    install -d "${THEME_DIR}"/{16,22,24}

    cp -r "${SRC_DIR}"/src/16/panel                                              "${THEME_DIR}/16"
    cp -r "${SRC_DIR}"/src/22/panel                                              "${THEME_DIR}/22"
    cp -r "${SRC_DIR}"/src/24/panel                                              "${THEME_DIR}/24"

    # Change icon color for dark theme
    sed -i "s/#dfdfdf/#505050/g" "${THEME_DIR}"/{16,22,24}/panel/*.svg

    cp -r "${SRC_DIR}"/links/16/panel                                            "${THEME_DIR}/16"
    cp -r "${SRC_DIR}"/links/22/panel                                            "${THEME_DIR}/22"
    cp -r "${SRC_DIR}"/links/24/panel                                            "${THEME_DIR}/24"

    # Link the common icons
    ln -sr "${STD_THEME_DIR}/scalable"                                           "${THEME_DIR}/scalable"
    ln -sr "${STD_THEME_DIR}/32"                                                 "${THEME_DIR}/32"
    ln -sr "${STD_THEME_DIR}/16/actions"                                         "${THEME_DIR}/16/actions"
    ln -sr "${STD_THEME_DIR}/16/apps"                                            "${THEME_DIR}/16/apps"
    ln -sr "${STD_THEME_DIR}/16/devices"                                         "${THEME_DIR}/16/devices"
    ln -sr "${STD_THEME_DIR}/16/mimetypes"                                       "${THEME_DIR}/16/mimetypes"
    ln -sr "${STD_THEME_DIR}/16/places"                                          "${THEME_DIR}/16/places"
    ln -sr "${STD_THEME_DIR}/16/status"                                          "${THEME_DIR}/16/status"
    ln -sr "${STD_THEME_DIR}/22/actions"                                         "${THEME_DIR}/22/actions"
    ln -sr "${STD_THEME_DIR}/22/devices"                                         "${THEME_DIR}/22/devices"
    ln -sr "${STD_THEME_DIR}/22/emblems"                                         "${THEME_DIR}/22/emblems"
    ln -sr "${STD_THEME_DIR}/22/mimetypes"                                       "${THEME_DIR}/22/mimetypes"
    ln -sr "${STD_THEME_DIR}/22/places"                                          "${THEME_DIR}/22/places"
    ln -sr "${STD_THEME_DIR}/24/actions"                                         "${THEME_DIR}/24/actions"
    ln -sr "${STD_THEME_DIR}/24/animations"                                      "${THEME_DIR}/24/animations"
    ln -sr "${STD_THEME_DIR}/24/devices"                                         "${THEME_DIR}/24/devices"
    ln -sr "${STD_THEME_DIR}/24/places"                                          "${THEME_DIR}/24/places"
    ln -sr "${STD_THEME_DIR}/symbolic"                                           "${THEME_DIR}/symbolic"
  fi

  if [[ "${brightprefix}" == '-dark' ]]; then
    local -r STD_THEME_DIR="${THEME_DIR%-dark}"

    install -d "${THEME_DIR}"/{16,22,24,symbolic}

    cp -r "${SRC_DIR}"/src/16/{actions,devices,places}                           "${THEME_DIR}/16"
    cp -r "${SRC_DIR}"/src/22/{actions,devices,places}                           "${THEME_DIR}/22"
    cp -r "${SRC_DIR}"/src/24/{actions,devices,places}                           "${THEME_DIR}/24"
    cp -r "${SRC_DIR}"/src/symbolic/*                                            "${THEME_DIR}/symbolic"

    # Change icon color for dark theme
    sed -i "s/#565656/#aaaaaa/g" "${THEME_DIR}"/{16,22,24}/actions/*.svg
    sed -i "s/#727272/#aaaaaa/g" "${THEME_DIR}"/{16,22,24}/{places,devices}/*.svg
    sed -i "s/#555555/#aaaaaa/g" "${THEME_DIR}"/symbolic/{actions,apps,categories,devices,emblems,emotes,mimetypes,places,status}/*.svg

    cp -r "${SRC_DIR}"/links/16/{actions,devices,places}                         "${THEME_DIR}/16"
    cp -r "${SRC_DIR}"/links/22/{actions,devices,places}                         "${THEME_DIR}/22"
    cp -r "${SRC_DIR}"/links/24/{actions,devices,places}                         "${THEME_DIR}/24"
    cp -r "${SRC_DIR}"/links/symbolic/*                                          "${THEME_DIR}/symbolic"

    # Link the common icons
    ln -sr "${STD_THEME_DIR}/scalable"                                           "${THEME_DIR}/scalable"
    ln -sr "${STD_THEME_DIR}/32"                                                 "${THEME_DIR}/32"
    ln -sr "${STD_THEME_DIR}/16/apps"                                            "${THEME_DIR}/16/apps"
    ln -sr "${STD_THEME_DIR}/16/mimetypes"                                       "${THEME_DIR}/16/mimetypes"
    ln -sr "${STD_THEME_DIR}/16/panel"                                           "${THEME_DIR}/16/panel"
    ln -sr "${STD_THEME_DIR}/16/status"                                          "${THEME_DIR}/16/status"
    ln -sr "${STD_THEME_DIR}/22/emblems"                                         "${THEME_DIR}/22/emblems"
    ln -sr "${STD_THEME_DIR}/22/mimetypes"                                       "${THEME_DIR}/22/mimetypes"
    ln -sr "${STD_THEME_DIR}/22/panel"                                           "${THEME_DIR}/22/panel"
    ln -sr "${STD_THEME_DIR}/24/animations"                                      "${THEME_DIR}/24/animations"
    ln -sr "${STD_THEME_DIR}/24/panel"                                           "${THEME_DIR}/24/panel"
  fi

  ln -sr "${THEME_DIR}/16"                                                       "${THEME_DIR}/16@2x"
  ln -sr "${THEME_DIR}/22"                                                       "${THEME_DIR}/22@2x"
  ln -sr "${THEME_DIR}/24"                                                       "${THEME_DIR}/24@2x"
  ln -sr "${THEME_DIR}/32"                                                       "${THEME_DIR}/32@2x"
  ln -sr "${THEME_DIR}/scalable"                                                 "${THEME_DIR}/scalable@2x"

  gtk-update-icon-cache "${THEME_DIR}"
}

while [ $# -gt 0 ]; do
  if [[ "$1" = "-a" ]]; then
    colors=("standard")
  elif [[ "$1" = "-c" ]]; then
    circle="true"
    echo -e "Install circular folder version! ..."
  elif [[ "$1" = "-d" ]]; then
    DEST_DIR="$2"
    shift
  elif [[ "$1" = "-n" ]]; then
    NAME="$2"
    shift
  elif [[ "$1" = "-h" ]]; then
    usage
    exit 0
  else
    colors=("$1")
  fi

  shift
done

# Default name is 'Tela-circle'
: "${NAME:=Tela-circle}"


# By default, only the standard color variant is selected
for color in "${colors[@]}"; do
  for bright in "${BRIGHT_VARIANTS[@]}"; do
    install_theme "${color}" "${bright}"
  done
done

