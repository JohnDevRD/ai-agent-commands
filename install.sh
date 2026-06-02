#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# ai-agent-commands - Instalador interactivo
# ═══════════════════════════════════════════════════════════════
# Compatible con: Linux, macOS, WSL, Git Bash
# Uso: ./install.sh
# ═══════════════════════════════════════════════════════════════

set -e

# ── Configuración ──
REPO_URL="https://github.com/JohnDevRD/ai-agent-commands"
REPO_BRANCH="main"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="${HOME}/.cache/ai-agent-commands"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ── Funciones auxiliares ──
print_banner() {
    echo -e "${CYAN}${BOLD}"
    cat << 'EOF'
╔════════════════════════════════════════════╗
║  🤖 AI Agent Commands - Instalador       ║
╚════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error()   { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info()    { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_header()  { echo -e "${CYAN}${BOLD}── $1 ──${NC}"; }

prompt() {
    local var_name="$1"
    local prompt_text="$2"
    local default="$3"
    if [ -n "$default" ]; then
        read -p "$(echo -e ${YELLOW}$prompt_text${NC}) [$default]: " input
        eval "$var_name=\"${input:-$default}\""
    else
        read -p "$(echo -e ${YELLOW}$prompt_text${NC}): " input
        eval "$var_name=\"$input\""
    fi
}

# ── Detectar destino de instalación ──
detect_install_target() {
    echo ""
    print_header "Destino de instalación"
    echo "  1) Proyecto actual (./.opencode/commands/)"
    echo "  2) Global del usuario (~/.config/opencode/commands/)"
    echo "  3) Personalizado"
    prompt TARGET_CHOICE "Elige una opción" "1"

    case "$TARGET_CHOICE" in
        1) INSTALL_DIR="$(pwd)/.opencode/commands" ;;
        2) INSTALL_DIR="${HOME}/.config/opencode/commands" ;;
        3)
            prompt INSTALL_DIR "Ruta completa de destino"
            ;;
        *) print_error "Opción inválida"; exit 1 ;;
    esac

    echo ""
    print_info "Destino seleccionado: $INSTALL_DIR"
}


# ── Clonar o actualizar repo ──
fetch_catalog() {
    print_header "Obteniendo catálogo"

    if [ -d "$CACHE_DIR/.git" ]; then
        print_info "Actualizando catálogo en caché..."
        cd "$CACHE_DIR"
        git pull --quiet origin "$REPO_BRANCH" 2>/dev/null || {
            print_warning "No se pudo actualizar, usando versión local"
        }
    else
        print_info "Clonando catálogo por primera vez..."
        mkdir -p "$(dirname "$CACHE_DIR")"
        git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$CACHE_DIR" 2>/dev/null || {
            print_error "No se pudo clonar el repo. Verifica tu conexión."
            print_info "Usando archivos locales del repo..."
            CACHE_DIR="$SCRIPT_DIR"
        }
    fi

    if [ ! -d "$CACHE_DIR" ]; then
        print_error "No se encontró el catálogo."
        exit 1
    fi
}

# ── Cargar categorías ──
load_categories() {
    CATEGORIES=()
    for dir in "$CACHE_DIR"/*/; do
        if [ -f "$dir/manifest.json" ]; then
            CATEGORIES+=("$(basename "$dir")")
        fi
    done
}

# ── Mostrar menú de categorías ──
show_categories() {
    print_header "Categorías disponibles"
    local i=1
    for cat in "${CATEGORIES[@]}"; do
        local manifest="$CACHE_DIR/$cat/manifest.json"
        local display
        display=$(grep -m1 '"displayName"' "$manifest" | sed 's/.*: "\(.*\)",*/\1/')
        local count
        count=$(grep -c '"id":' "$manifest" 2>/dev/null || echo "0")
        echo -e "  ${BOLD}$i)${NC} $display ${YELLOW}($count comandos)${NC}"
        ((i++))
    done
    echo -e "  ${BOLD}all)${NC} Instalar todo"
    echo -e "  ${BOLD}q)${NC} Salir"
}

# ── Mostrar comandos de una categoría ──
show_commands_in_category() {
    local category="$1"
    local manifest="$CACHE_DIR/$category/manifest.json"
    print_header "Comandos en: $category"

    local i=1
    local current_id=""
    while IFS= read -r line; do
        if [[ "$line" =~ \"id\":\ \"([^\"]+)\" ]]; then
            current_id="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ \"description\":\ \"([^\"]+)\" ]] && [ -n "$current_id" ]; then
            local desc="${BASH_REMATCH[1]}"
            echo -e "  ${BOLD}$i)${NC} $current_id - $desc"
            ((i++))
            current_id=""
        fi
    done < "$manifest"
}

# ── Instalar comando ──
install_command() {
    local category="$1"
    local cmd_file="$2"
    local source="$CACHE_DIR/$category/$cmd_file"

    if [ ! -f "$source" ]; then
        print_error "Archivo no encontrado: $source"
        return 1
    fi

    mkdir -p "$INSTALL_DIR"

    if [ -f "$INSTALL_DIR/$cmd_file" ]; then
        print_warning "Sobrescribiendo: $cmd_file"
    fi

    cp "$source" "$INSTALL_DIR/$cmd_file"

# ── Flujo principal ──
main() {
    print_banner
    detect_install_target
    fetch_catalog
    load_categories

    if [ ${#CATEGORIES[@]} -eq 0 ]; then
        print_error "No se encontraron categorías en el catálogo."
        exit 1
    fi

    while true; do
        echo ""
        show_categories
        echo ""
        prompt CHOICE "Selecciona categoría, 'all' o 'q'" ""

        case "$CHOICE" in
            q|Q) print_info "Saliendo..."; exit 0 ;;
            all|ALL)
                print_header "Instalando todas las categorías"
                for cat in "${CATEGORIES[@]}"; do
                    for file in "$CACHE_DIR/$cat"/*.md; do
                        [ -f "$file" ] && install_command "$cat" "$(basename "$file")"
                    done
                done
                print_success "¡Todo instalado!"
                break
                ;;
            *)
                if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt ${#CATEGORIES[@]} ]; then
                    print_error "Opción inválida"
                    continue
                fi

                local selected_cat="${CATEGORIES[$((CHOICE-1))]}"
                show_commands_in_category "$selected_cat"
                echo ""
                prompt CMD_CHOICE "Selecciona comandos (ej: 1,3,4 o 'all')" "all"

                if [ "$CMD_CHOICE" = "all" ] || [ "$CMD_CHOICE" = "ALL" ]; then
                    for file in "$CACHE_DIR/$selected_cat"/*.md; do
                        [ -f "$file" ] && install_command "$selected_cat" "$(basename "$file")"
                    done
                else
                    IFS=',' read -ra SELECTED <<< "$CMD_CHOICE"
                    local i=1
                    for file in "$CACHE_DIR/$selected_cat"/*.md; do
                        [ -f "$file" ] || continue
                        for sel in "${SELECTED[@]}"; do
                            if [ "$i" -eq "$sel" ]; then
                                install_command "$selected_cat" "$(basename "$file")"
                            fi
                        done
                        ((i++))
                    done
                fi

                echo ""
                prompt CONTINUE "¿Instalar otra categoría?" "s"
                if [[ ! "$CONTINUE" =~ ^[sSyY] ]]; then
                    break
                fi
                ;;
        esac
    done

    echo ""
    print_header "Resumen"
    print_success "Comandos instalados en: $INSTALL_DIR"
    echo ""
    print_info "Comandos disponibles en tu agente:"
    if [ -d "$INSTALL_DIR" ]; then
        for f in "$INSTALL_DIR"/*.md; do
            [ -f "$f" ] && echo -e "  ${GREEN}/$(basename "$f" .md)${NC}"
        done
    fi
    echo ""
    print_success "¡Listo! Ya puedes usar los comandos en tu agente IA 🎉"
}

main "$@"

    print_success "Instalado: $cmd_file"
}
