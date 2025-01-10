#!/bin/bash

# Definição de cores
RESET="\033[0m"
BLUE="\033[1;34m"   # Azul
GREEN="\033[1;32m"  # Verde
YELLOW="\033[1;33m" # Amarelo
RED="\033[1;31m"    # Vermelho
PURPLE="\033[1;35m" # Roxo para debug

# Definição de emojis
INFO_EMOJI=""
SUCCESS_EMOJI="✔  "
WARN_EMOJI="⚠️ "
ERROR_EMOJI="✘  "
DEBUG_EMOJI="🐛 "

# Função log
log() {
  local level=$1
  local message=$2

  # Usando um switch-like para definir a cor e emoji de acordo com o nível
  case $level in
  info)
    color=$BLUE
    emoji=$INFO_EMOJI
    ;;
  success)
    color=$GREEN
    emoji=$SUCCESS_EMOJI
    ;;
  warn)
    color=$YELLOW
    emoji=$WARN_EMOJI
    ;;
  error)
    color=$RED
    emoji=$ERROR_EMOJI
    ;;
  debug)
    color=$PURPLE
    emoji=$DEBUG_EMOJI
    ;;
  *)
    color=$RESET # Default para 'info'
    emoji=$INFO_EMOJI
    ;;
  esac

  # Exibe a mensagem colorida com o emoji prefixado
  echo -e "${color}${emoji}$message$RESET"
}

# Exemplos de uso
# log "info" "Iniciando o processo de instalação do pacote X."
# log "success" "O pacote X foi instalado com sucesso!"
# log "warn" "A versão atual do pacote Y pode estar *desatualizada*."
# log "error" "Falha ao instalar o pacote Z."
# log "debug" "Essa é uma mensagem genérica de debugging."
# log "undefined" "Essa mensagem deve aparecer como info, pois 'undefined' não está definido."

# Variável global para armazenar o estado da verificação
APT_UPDATED=false

# Função para verificar pacotes do sistema, usando variável global
check_system_packages() {
  if [ "$APT_UPDATED" = false ]; then
    log "info" "🔍 Verificando pacotes do sistema..."
    sudo apt update -y
    echo -e "\n"
    APT_UPDATED=true
  fi
}

# Função para instalar ou atualizar pacotes essenciais
install_package() {
  PACKAGE=$1

  # Chama a função de verificação de pacotes
  check_system_packages

  log "info" "📦 Verificando se o pacote \`$PACKAGE\` está instalado ou se precisa ser atualizado."

  # Verifica se o pacote está instalado
  if dpkg -l | grep -q $PACKAGE; then
    # Se o pacote está instalado, verifica a versão
    INSTALLED_VERSION=$(dpkg-query -W -f='${Version}' $PACKAGE)
    # log "info" "🔧 $PACKAGE já está instalado. Verificando atualizações..."

    # Atualiza o pacote se necessário
    sudo apt install --only-upgrade $PACKAGE -y >/dev/null 2>&1

    # Verifica a versão após a atualização
    UPDATED_VERSION=$(dpkg-query -W -f='${Version}' $PACKAGE)

    # Se a versão foi atualizada, exibe o sucesso
    if [ "$INSTALLED_VERSION" != "$UPDATED_VERSION" ]; then
      log "success" "$PACKAGE atualizado para a versão $UPDATED_VERSION!"
    else
      log "success" "Você já está usando a versão mais recente do $PACKAGE ($INSTALLED_VERSION).\n"
    fi
  else
    # Se o pacote não está instalado, instala-o
    log "info" "🚨 $PACKAGE não encontrado. Instalando..."
    sudo apt install $PACKAGE -y >/dev/null 2>&1 && log "success" "$PACKAGE instalado com sucesso\n" || log "error" "Falha na instalação de $PACKAGE\n"
  fi
}

# Função para instalar o NVM (Node Version Manager)
install_nvm() {
  log "info" "📦 Verificando o pacote \`NVM\` para instalação ou atualização..."

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

  # Carrega o NVM para a sessão atual
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # Isso carrega o NVM
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # Isso carrega o autocomplete do NVM

  log "success" "NVM instalado com sucesso!"
}

# Função para instalar ou atualizar o NVM
install_or_update_nvm() {
  log "info" "📦 Verificando o \`NVM\` para instalação ou atualização..."

  LATEST_VERSION=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep '"tag_name"' | sed 's/.*"tag_name": "\(.*\)",/\1/')
  LATEST_VERSION=${LATEST_VERSION#v} # Remove o 'v' da versão

  # Carrega o NVM para garantir que podemos verificar a versão
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # Isso carrega o NVM

  # Se o NVM não estiver instalado, chama a função para instalá-lo
  if ! command -v nvm &>/dev/null; then
    install_nvm
  else
    INSTALLED_VERSION=$(nvm -v)
    # Se a versão instalada não for a mais recente, atualiza o NVM
    if [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then
      log "info" "🔧 Atualizando o NVM..."
      install_nvm
      log "success" "NVM atualizado para a versão $LATEST_VERSION!\n"
    else
      log "success" "Você já está usando a versão mais recente do NVM ($INSTALLED_VERSION).\n"
    fi
  fi
}

# Função para atualizar o NPM
update_npm() {
  log "info" "📦 Verificando o NPM para instalação ou atualização..."

  # Verifica a versão instalada do NPM
  INSTALLED_VERSION=$(npm -v)

  # Obtém a versão mais recente do NPM
  LATEST_VERSION=$(npm show npm version)

  # Compara as versões
  if [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then
    log "info" "🔧 Atualizando o NPM..."
    npm install --global npm@latest || log "error" "Falha na atualização do NPM"
    log "success" "NPM atualizado para a versão $LATEST_VERSION!\n"
  else
    log "success" "Você já está usando a versão mais recente do NPM ($INSTALLED_VERSION).\n"
  fi
}

# Função principal
main() {
  install_package "build-essential"
  install_package "curl"
  install_package "wget"
  install_package "git"

  install_or_update_nvm

  update_npm

  log "success" "Instalação e configuração de dependências do projeto concluídas com sucesso."
}

# Executa a função principal
main
