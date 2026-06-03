#!/usr/bin/env bash
# =============================================================================
# ai-agent-commands - Instalador interactivo
# =============================================================================
# Compatible con: Linux, macOS, WSL, Git Bash
# Uso:
#   curl -fsSL https://raw.githubusercontent.com/JohnDevRD/ai-agent-commands/main/install.sh -o install.sh && bash install.sh
#   ./install.sh
# =============================================================================

set -o pipefail

# -- Configuracion --
REPO_URL="https://github.com/JohnDevRD/ai-agent-commands"
REPO_BRANCH="main"
VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="${HOME}/.cache/ai-agent-commands"

# Contadores
INSTALLED_COUNT=0
INSTALLED_FILES=()

# -- Colores --
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DARK_CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
DARK_GRAY='\033[0;90m'
NC='\033[0m'

# =============================================================================
# FUNCIONES DE UI
# =============================================================================

print_blank() { echo ""; }

print_banner() {
    local width=62
    print_blank
    echo -e "${DARK_CYAN}$(printf '=%.0s' $(seq 1 $width))${NC}"
    echo ""
    echo -e "${CYAN}    ___    ____   ___                    __${NC}"
    echo -e "${CYAN}   /   |  /  _/  /   | ____ ____  ____  / /_${NC}"
    echo -e "${CYAN}  / /| |  / /   / /| |/ __ \`/ _ \/ __ \/ __/${NC}"
    echo -e "${CYAN} / ___ |_/ /   / ___ / /_/ /  __/ / / / /_${NC}"
    echo -e "${CYAN}/_/  |_/___/  /_/  |_\__, /\___/_/ /_/\__/${NC}"
    echo -e "${DARK_CYAN}                    /____/  Commands${NC}"
    echo ""
    echo -e "  ${WHITE}Instalador Interactivo  v${VERSION}${NC}"
    echo -e "  ${DARK_GRAY}${REPO_URL}${NC}"
    echo ""
    echo -e "${DARK_CYAN}$(printf '=%.0s' $(seq 1 $width))${NC}"
    print_blank
}

print_section_header() {
    local title="$1"
    local line
    line=$(printf '─%.0s' $(seq 1 60))
    print_blank
    echo -e "${DARK_GRAY}${line}${NC}"
    echo -e "  ${WHITE}>> ${title}${NC}"
    echo -e "${DARK_GRAY}${line}${NC}"
}

print_success() { printf "  ${GREEN}[+]${NC} ${WHITE}%s${NC}\n" "$1"; }
print_error()   { printf "  ${RED}[x]${NC} ${WHITE}%s${NC}\n" "$1"; }
print_warning() { printf "  ${YELLOW}[!]${NC} ${WHITE}%s${NC}\n" "$1"; }
print_info()    { printf "  ${CYAN}[i]${NC} ${GRAY}%s${NC}\n" "$1"; }
print_step()    { printf "  ${DARK_CYAN}[>]${NC} ${WHITE}%s${NC}\n" "$1"; }

prompt_input() {
    local var_name="$1"
    local prompt_text="$2"
    local default="$3"
    local input

    echo ""
    if [ -n "$default" ]; then
        printf "  ${WHITE}%s${NC} ${DARK_GRAY}[${NC}${YELLOW}%s${NC}${DARK_GRAY}]${NC} ${DARK_GRAY}:${NC} " \
               "$prompt_text" "$default"
        read -r input </dev/tty || input=""
        eval "$var_name=\"${input:-$default}\""
    else
        printf "  ${WHITE}%s${NC} ${DARK_GRAY}:${NC} " "$prompt_text"
        read -r input </dev/tty || input=""
        eval "$var_name=\"$input\""
    fi
}

show_spinner() {
    local message="$1"
    local pid="$2"
    local frames=('|' '/' '-' '\')
    local i=0

    echo ""
    while kill -0 "$pid" 2>/dev/null; do
        local frame="${frames[$((i % 4))]}"
        printf "\r  ${CYAN}[%s]${NC} ${WHITE}%s...${NC}" "$frame" "$message"
        sleep 0.12
        ((i++))
    done
    printf "\r  ${GREEN}[+]${NC} ${WHITE}%s... Listo.   ${NC}\n" "$message"
}

# =============================================================================
# DESTINO DE INSTALACION
# =============================================================================

detect_install_target() {
    print_section_header "Destino de instalacion"

    echo ""
    printf "  ${YELLOW}[1]${NC}  ${WHITE}%-26s${NC} ${DARK_GRAY}./.opencode/commands/${NC}\n" "Proyecto actual"
    printf "  ${YELLOW}[2]${NC}  ${WHITE}%-26s${NC} ${DARK_GRAY}~/.config/opencode/commands/${NC}\n" "Global del usuario"
    printf "  ${YELLOW}[3]${NC}  ${WHITE}Ruta personalizada${NC}\n"

    prompt_input "choice" "Elegir una opcion" "1"

    case "$choice" in
        1) INSTALL_DIR="$(pwd)/.opencode/commands" ;;
        2) INSTALL_DIR="${HOME}/.config/opencode/commands" ;;
        3) prompt_input "INSTALL_DIR" "Ruta completa de destino" "" ;;
        *)
            print_error "Opcion invalida. Saliendo."
            exit 1
            ;;
    esac

    print_blank
    print_info "Destino: $INSTALL_DIR"
}

# =============================================================================
# CATALOGO
# =============================================================================

fetch_catalog() {
    print_section_header "Obteniendo catalogo"
    print_blank

    if [ -d "$CACHE_DIR/.git" ]; then
        print_step "Actualizando catalogo en cache"
        (cd "$CACHE_DIR" && git pull --quiet origin "$REPO_BRANCH" 2>/dev/null) &
        local pid=$!
        show_spinner "Actualizando catalogo en cache" "$pid"
        wait "$pid" && \
            print_success "Catalogo actualizado correctamente." || \
            print_warning "No se pudo actualizar el cache; se usara la version local existente."
    else
        print_step "Clonando catalogo por primera vez"
        mkdir -p "$(dirname "$CACHE_DIR")"
        (git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$CACHE_DIR" 2>/dev/null) &
        local pid=$!
        show_spinner "Clonando catalogo" "$pid"
        if wait "$pid"; then
            print_success "Catalogo clonado correctamente."
        else
            print_error "No se pudo clonar el repositorio. Verifica tu conexion y la instalacion de git."
            if [ -d "$SCRIPT_DIR/.git" ]; then
                print_warning "Usando archivos locales del repositorio como respaldo."
                CACHE_DIR="$SCRIPT_DIR"
            else
                exit 1
            fi
        fi
    fi

    if [ ! -d "$CACHE_DIR" ]; then
        print_error "No se encontro el catalogo en: $CACHE_DIR"
        exit 1
    fi
}

# =============================================================================
# HELPERS DEL CATALOGO
# =============================================================================

# Requiere jq
require_jq() {
    if ! command -v jq &>/dev/null; then
        print_error "Se requiere 'jq' para leer el catalogo. Instálalo con: apt install jq / brew install jq"
        exit 1
    fi
}

load_categories() {
    CATEGORIES=()
    for dir in "$CACHE_DIR"/*/; do
        if [ -f "$dir/manifest.json" ]; then
            CATEGORIES+=("$(basename "$dir")")
        fi
    done
    IFS=$'\n' CATEGORIES=($(printf '%s\n' "${CATEGORIES[@]}" | sort)); unset IFS
}

show_categories() {
    print_section_header "Categorias disponibles"
    print_blank

    local i=1
    for cat in "${CATEGORIES[@]}"; do
        local manifest="$CACHE_DIR/$cat/manifest.json"
        local display count label

        display=$(jq -r '.displayName // empty' "$manifest" 2>/dev/null)
        count=$(jq '.commands | length' "$manifest" 2>/dev/null || echo "0")
        label=$(printf '%-30s' "$display")

        printf "  ${DARK_GRAY}[${NC}${YELLOW}%s${NC}${DARK_GRAY}]${NC} ${WHITE}%s${NC} ${DARK_GRAY}%s comando(s)${NC}\n" \
               "$i" "$label" "$count"
        ((i++))
    done

    echo ""
    printf "  ${DARK_GRAY}[${NC}${CYAN}todo${NC}${DARK_GRAY}]${NC}  ${WHITE}Instalar todas las categorias${NC}\n"
    printf "  ${DARK_GRAY}[${NC}${RED}q${NC}${DARK_GRAY}]${NC}     ${WHITE}Salir${NC}\n"
}

show_commands_in_category() {
    local category="$1"
    local manifest="$CACHE_DIR/$category/manifest.json"
    local display

    display=$(jq -r '.displayName // empty' "$manifest" 2>/dev/null)
    print_section_header "Comandos en: ${display}"
    print_blank

    local i=1
    while IFS= read -r line; do
        local id desc
        id=$(echo "$line" | jq -r '.id // empty')
        desc=$(echo "$line" | jq -r '.description // empty')
        printf "  ${DARK_GRAY}[${NC}${YELLOW}%s${NC}${DARK_GRAY}]${NC} ${WHITE}%-30s${NC} ${DARK_GRAY}%s${NC}\n" \
               "$i" "$id" "$desc"
        ((i++))
    done < <(jq -c '.commands[]' "$manifest" 2>/dev/null)
}

get_commands_from_category() {
    local category="$1"
    for file in "$CACHE_DIR/$category"/*.md; do
        [ -f "$file" ] && basename "$file"
    done
}

get_command_count() {
    local category="$1"
    local manifest="$CACHE_DIR/$category/manifest.json"
    jq '.commands | length' "$manifest" 2>/dev/null || echo 0
}

install_command() {
    local category="$1"
    local cmd_file="$2"
    local source="$CACHE_DIR/$category/$cmd_file"

    if [ ! -f "$source" ]; then
        print_error "Archivo no encontrado: $source"
        return 1
    fi

    if ! mkdir -p "$INSTALL_DIR"; then
        print_error "No se pudo crear el directorio: $INSTALL_DIR"
        return 1
    fi

    if [ -f "$INSTALL_DIR/$cmd_file" ]; then
        print_warning "Sobrescribiendo: $cmd_file"
    fi

    if ! cp "$source" "$INSTALL_DIR/$cmd_file"; then
        print_error "Fallo la copia de: $cmd_file"
        return 1
    fi

    print_success "Instalado: $cmd_file"
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    INSTALLED_FILES+=("$cmd_file")
}

install_all_categories() {
    print_section_header "Instalando todas las categorias"
    for cat in "${CATEGORIES[@]}"; do
        while IFS= read -r file; do
            [ -n "$file" ] && install_command "$cat" "$file"
        done < <(get_commands_from_category "$cat")
    done
}

# =============================================================================
# RESUMEN FINAL
# =============================================================================

print_summary() {
    local width=62
    print_blank
    echo -e "${DARK_CYAN}$(printf '=%.0s' $(seq 1 $width))${NC}"
    echo -e "  ${WHITE}RESUMEN DE INSTALACION${NC}"
    echo -e "${DARK_CYAN}$(printf '=%.0s' $(seq 1 $width))${NC}"
    print_blank

    print_success "Directorio: $INSTALL_DIR"
    print_info    "Total instalados: ${INSTALLED_COUNT} comando(s)"

    if [ "${#INSTALLED_FILES[@]}" -gt 0 ]; then
        print_blank
        echo -e "  ${WHITE}Comandos disponibles en tu agente IA:${NC}"
        echo -e "  ${DARK_GRAY}$(printf '─%.0s' $(seq 1 40))${NC}"

        IFS=$'\n' sorted=($(printf '%s\n' "${INSTALLED_FILES[@]}" | sort)); unset IFS
        for f in "${sorted[@]}"; do
            local name="${f%.md}"
            printf "    ${DARK_CYAN}/${NC}${WHITE}%s${NC}\n" "$name"
        done

    elif [ -d "$INSTALL_DIR" ]; then
        print_blank
        echo -e "  ${WHITE}Comandos disponibles en tu agente IA:${NC}"
        echo -e "  ${DARK_GRAY}$(printf '─%.0s' $(seq 1 40))${NC}"

        for f in "$INSTALL_DIR"/*.md; do
            [ -f "$f" ] || continue
            local name
            name=$(basename "$f" .md)
            printf "    ${DARK_CYAN}/${NC}${WHITE}%s${NC}\n" "$name"
        done
    fi

    print_blank
    echo -e "${DARK_CYAN}$(printf '=%.0s' $(seq 1 $width))${NC}"
    echo -e "  ${GREEN}Listo. Ya puedes usar los comandos en tu agente IA.${NC}"
    echo -e "${DARK_CYAN}$(printf '=%.0s' $(seq 1 $width))${NC}"
    print_blank
}

# =============================================================================
# FLUJO PRINCIPAL
# =============================================================================

main() {
    print_banner
    require_jq
    detect_install_target
    fetch_catalog
    load_categories

    if [ "${#CATEGORIES[@]}" -eq 0 ]; then
        print_error "No se encontraron categorias en el catalogo."
        exit 1
    fi

    local stop_installing=false

    while true; do
        print_blank
        show_categories
        print_blank
        prompt_input "CHOICE" "Selecciona categoria, 'todo' o 'q'" ""

        if [ -z "$CHOICE" ]; then
            print_info "No se selecciono ninguna opcion. Saliendo..."
            break
        fi

        case "${CHOICE,,}" in
            q)
                print_info "Saliendo..."
                exit 0
                ;;
            todo|all)
                install_all_categories
                stop_installing=true
                ;;
            *)
                if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || \
                   [ "$CHOICE" -lt 1 ] || \
                   [ "$CHOICE" -gt "${#CATEGORIES[@]}" ]; then
                    print_error "Opcion invalida. Ingresa un numero del 1 al ${#CATEGORIES[@]}, 'todo' o 'q'."
                    continue
                fi

                local selected_cat="${CATEGORIES[$((CHOICE - 1))]}"
                show_commands_in_category "$selected_cat"

                print_blank
                prompt_input "CMD_CHOICE" "Selecciona comandos (ej: 1,3,4 o 'todo')" "todo"

                local total_cmds
                total_cmds=$(get_command_count "$selected_cat")

                if [[ "${CMD_CHOICE,,}" =~ ^(todo|all)$ ]]; then
                    while IFS= read -r file; do
                        [ -n "$file" ] && install_command "$selected_cat" "$file"
                    done < <(get_commands_from_category "$selected_cat")
                else
                    IFS=',' read -ra SELECTED <<< "$CMD_CHOICE"
                    local i=1
                    while IFS= read -r file; do
                        [ -n "$file" ] || continue
                        for sel in "${SELECTED[@]}"; do
                            sel="${sel// /}"
                            if [[ "$sel" =~ ^[0-9]+$ ]] && [ "$i" -eq "$sel" ]; then
                                install_command "$selected_cat" "$file"
                            fi
                        done
                        ((i++))
                    done < <(get_commands_from_category "$selected_cat")
                fi

                print_blank
                prompt_input "CONTINUE_CHOICE" "Instalar otra categoria? (s/n)" "s"
                if [[ ! "${CONTINUE_CHOICE,,}" =~ ^[sy] ]]; then
                    stop_installing=true
                fi
                ;;
        esac

        if [ "$stop_installing" = true ]; then
            break
        fi
    done

    print_summary
}

main "$@"
