#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# ai-agent-commands - Instalador interactivo
# ═══════════════════════════════════════════════════════════════════
# Compatible con: Linux, macOS, WSL, Git Bash
# Uso:
#   curl -fsSL https://raw.githubusercontent.com/JohnDevRD/ai-agent-commands/main/install.sh | bash
#   ./install.sh
# ═══════════════════════════════════════════════════════════════════

set -o pipefail

# ── Configuración ──
REPO_URL="https://github.com/JohnDevRD/ai-agent-commands"
REPO_BRANCH="main"
VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="${HOME}/.cache/ai-agent-commands"

# Contadores
INSTALLED_COUNT=0
INSTALLED_FILES=()

# ── Colores ──
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DARK_CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
DARK_GRAY='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m'

# ═══════════════════════════════════════════════════════════════════
# FUNCIONES DE UI
# ═══════════════════════════════════════════════════════════════════

print_blank() { echo ""; }

print_banner() {
    local width=66
    print_blank
    echo -e "${DARK_CYAN}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}    ___    ____   ___                    __${NC}"
    echo -e "${CYAN}${BOLD}   /   |  /  _/  /   | ____ ____  ____  / /_${NC}"
    echo -e "${CYAN}${BOLD}  / /| |  / /   / /| |/ __ \`/ _ \/ __ \/ __/${NC}"
    echo -e "${CYAN}${BOLD} / ___ |_/ /   / ___ / /_/ /  __/ / / / /_${NC}"
    echo -e "${CYAN}${BOLD}/_/  |_/___/  /_/  |_\__, /\___/_/ /_/\__/${NC}"
    echo -e "${DARK_CYAN}${BOLD}                    /____/  Commands${NC}"
    echo ""
    echo -e "  ${WHITE}Instalador Interactivo  v${VERSION}${NC}"
    echo -e "  ${DARK_GRAY}${REPO_URL}${NC}"
    echo ""
    echo -e "${DARK_CYAN}$(printf '═%.0s' $(seq 1 $width))${NC}"
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

print_success() { echo -e "  ${GREEN}[+]${NC} ${WHITE}$1${NC}"; }
print_error()   { echo -e "  ${RED}[x]${NC} ${WHITE}$1${NC}"; }
print_warning() { echo -e "  ${YELLOW}[!]${NC} ${WHITE}$1${NC}"; }
print_info()    { echo -e "  ${CYAN}[i]${NC} ${GRAY}$1${NC}"; }
print_step()    { echo -e "  ${DARK_CYAN}[>]${NC} ${WHITE}$1${NC}"; }

prompt() {
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

# ═══════════════════════════════════════════════════════════════════
# DESTINO DE INSTALACIÓN
# ═══════════════════════════════════════════════════════════════════

detect_install_target() {
    print_section_header "Destino de instalación"
    echo ""

    echo -e "  ${YELLOW}[1]${NC}  ${WHITE}Proyecto actual         ${DARK_GRAY}./.opencode/commands/${NC}"
    echo -e "  ${YELLOW}[2]${NC}  ${WHITE}Global del usuario      ${DARK_GRAY}~/.config/opencode/commands/${NC}"
    echo -e "  ${YELLOW}[3]${NC}  ${WHITE}Ruta personalizada${NC}"

    prompt TARGET_CHOICE "Elige una opción" "1"

    case "$TARGET_CHOICE" in
        1) INSTALL_DIR="$(pwd)/.opencode/commands" ;;
        2) INSTALL_DIR="${HOME}/.config/opencode/commands" ;;
        3) prompt INSTALL_DIR "Ruta completa de destino" "" ;;
        *) print_error "Opción inválida. Saliendo."; exit 1 ;;
    esac

    echo ""
    print_info "Destino: $INSTALL_DIR"
}

# ═══════════════════════════════════════════════════════════════════
# CATÁLOGO
# ═══════════════════════════════════════════════════════════════════

fetch_catalog() {
    print_section_header "Obteniendo catálogo"
    echo ""

    if [ -d "$CACHE_DIR/.git" ]; then
        print_step "Actualizando catálogo en caché"
        cd "$CACHE_DIR"
        if git pull --quiet origin "$REPO_BRANCH" 2>/dev/null; then
            print_success "Catálogo actualizado correctamente."
        else
            print_warning "No se pudo actualizar; se usará la versión local existente."
        fi
    else
        print_step "Clonando catálogo por primera vez"
        mkdir -p "$(dirname "$CACHE_DIR")"
        if git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$CACHE_DIR" 2>/dev/null; then
            print_success "Catálogo clonado correctamente."
        else
            print_error "No se pudo clonar el repositorio. Verifica tu conexión y la instalación de git."
            if [ -d "$SCRIPT_DIR/.git" ]; then
                print_warning "Usando archivos locales del repositorio como respaldo."
                CACHE_DIR="$SCRIPT_DIR"
            else
                exit 1
            fi
        fi
    fi

    if [ ! -d "$CACHE_DIR" ]; then
        print_error "No se encontró el catálogo en: $CACHE_DIR"
        exit 1
    fi
}

# ═══════════════════════════════════════════════════════════════════
# HELPERS DEL CATÁLOGO
# ═══════════════════════════════════════════════════════════════════

load_categories() {
    CATEGORIES=()
    for dir in "$CACHE_DIR"/*/; do
        if [ -f "$dir/manifest.json" ]; then
            CATEGORIES+=("$(basename "$dir")")
        fi
    done
}

show_categories() {
    print_section_header "Categorías disponibles"
    echo ""

    local i=1
    for cat in "${CATEGORIES[@]}"; do
        local manifest="$CACHE_DIR/$cat/manifest.json"
        local display
        display=$(grep -m1 '"displayName"' "$manifest" | sed 's/.*: "\(.*\)",*/\1/')
        local count
        count=$(grep -c '"id":' "$manifest" 2>/dev/null || echo "0")
        local label
        label=$(printf '%-30s' "$display")

        echo -e "  ${DARK_GRAY}[${NC}${YELLOW}${i}${NC}${DARK_GRAY}]${NC} ${WHITE}${label}${NC} ${DARK_GRAY}${count} comando(s)${NC}"
        ((i++))
    done

    echo ""
    echo -e "  ${DARK_GRAY}[${NC}${CYAN}todo${NC}${DARK_GRAY}]${NC}  ${WHITE}Instalar todas las categorías${NC}"
    echo -e "  ${DARK_GRAY}[${NC}${RED}q${NC}${DARK_GRAY}]${NC}     ${WHITE}Salir${NC}"
}

show_commands_in_category() {
    local category="$1"
    local manifest="$CACHE_DIR/$category/manifest.json"
    local display
    display=$(grep -m1 '"displayName"' "$manifest" | sed 's/.*: "\(.*\)",*/\1/')

    print_section_header "Comandos en: ${display}"
    echo ""

    local i=1
    local current_id=""
    while IFS= read -r line; do
        if [[ "$line" =~ \"id\":\ \"([^\"]+)\" ]]; then
            current_id="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ \"description\":\ \"([^\"]+)\" ]] && [ -n "$current_id" ]; then
            local desc="${BASH_REMATCH[1]}"
            echo -e "  ${DARK_GRAY}[${NC}${YELLOW}${i}${NC}${DARK_GRAY}]${NC} ${WHITE}${current_id}${NC}  ${DARK_GRAY}${desc}${NC}"
            ((i++))
            current_id=""
        fi
    done < "$manifest"
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
        print_error "Falló la copia de: $cmd_file"
        return 1
    fi

    print_success "Instalado: $cmd_file"

    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    INSTALLED_FILES+=("$cmd_file")
}

install_all_categories() {
    print_section_header "Instalando todas las categorías"
    for cat in "${CATEGORIES[@]}"; do
        for file in "$CACHE_DIR/$cat"/*.md; do
            [ -f "$file" ] && install_command "$cat" "$(basename "$file")"
        done
    done
}

# ═══════════════════════════════════════════════════════════════════
# RESUMEN FINAL
# ═══════════════════════════════════════════════════════════════════

print_summary() {
    local width=66
    echo ""
    echo -e "${DARK_CYAN}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo -e "  ${WHITE}RESUMEN DE INSTALACIÓN${NC}"
    echo -e "${DARK_CYAN}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo ""

    print_success "Directorio: $INSTALL_DIR"
    print_info    "Total instalados: ${INSTALLED_COUNT} comando(s)"

    if [ "${#INSTALLED_FILES[@]}" -gt 0 ]; then
        echo ""
        echo -e "  ${WHITE}Comandos disponibles en tu agente IA:${NC}"
        echo -e "  ${DARK_GRAY}$(printf '─%.0s' $(seq 1 40))${NC}"

        # Ordenar y mostrar
        IFS=$'\n' sorted=($(sort <<<"${INSTALLED_FILES[*]}")); unset IFS
        for f in "${sorted[@]}"; do
            local name="${f%.md}"
            echo -e "    ${DARK_CYAN}/${NC}${WHITE}${name}${NC}"
        done

    elif [ -d "$INSTALL_DIR" ]; then
        echo ""
        echo -e "  ${WHITE}Comandos disponibles en tu agente IA:${NC}"
        echo -e "  ${DARK_GRAY}$(printf '─%.0s' $(seq 1 40))${NC}"

        for f in "$INSTALL_DIR"/*.md; do
            [ -f "$f" ] || continue
            local name
            name=$(basename "$f" .md)
            echo -e "    ${DARK_CYAN}/${NC}${WHITE}${name}${NC}"
        done
    fi

    echo ""
    echo -e "${DARK_CYAN}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo -e "  ${GREEN}Listo. Ya puedes usar los comandos en tu agente IA.${NC}"
    echo -e "${DARK_CYAN}$(printf '═%.0s' $(seq 1 $width))${NC}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════
# FLUJO PRINCIPAL
# ═══════════════════════════════════════════════════════════════════

main() {
    print_banner
    detect_install_target
    fetch_catalog
    load_categories

    if [ "${#CATEGORIES[@]}" -eq 0 ]; then
        print_error "No se encontraron categorías en el catálogo."
        exit 1
    fi

    while true; do
        echo ""
        show_categories
        echo ""
        prompt CHOICE "Selecciona categoría, 'todo' o 'q'" ""

        if [ -z "$CHOICE" ]; then
            print_info "No se seleccionó ninguna opción. Saliendo..."
            break
        fi

        case "${CHOICE,,}" in
            q)
                print_info "Saliendo..."
                exit 0
                ;;
            todo|all)
                install_all_categories
                break
                ;;
            *)
                if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || \
                   [ "$CHOICE" -lt 1 ] || \
                   [ "$CHOICE" -gt "${#CATEGORIES[@]}" ]; then
                    print_error "Opción inválida. Ingresa un número del 1 al ${#CATEGORIES[@]}, 'todo' o 'q'."
                    continue
                fi

                local selected_cat="${CATEGORIES[$((CHOICE - 1))]}"
                show_commands_in_category "$selected_cat"

                echo ""
                prompt CMD_CHOICE "Selecciona comandos (ej: 1,3,4 o 'todo')" "todo"

                if [[ "${CMD_CHOICE,,}" =~ ^(todo|all)$ ]]; then
                    for file in "$CACHE_DIR/$selected_cat"/*.md; do
                        [ -f "$file" ] && install_command "$selected_cat" "$(basename "$file")"
                    done
                else
                    IFS=',' read -ra SELECTED <<< "$CMD_CHOICE"
                    local i=1
                    for file in "$CACHE_DIR/$selected_cat"/*.md; do
                        [ -f "$file" ] || continue
                        for sel in "${SELECTED[@]}"; do
                            sel="${sel// /}"
                            if [ "$i" -eq "$sel" ]; then
                                install_command "$selected_cat" "$(basename "$file")"
                            fi
                        done
                        ((i++))
                    done
                fi

                echo ""
                prompt CONTINUE "¿Instalar otra categoría? (s/n)" "s"
                if [[ ! "${CONTINUE,,}" =~ ^[sy] ]]; then
                    break
                fi
                ;;
        esac
    done

    print_summary
}

main "$@"
