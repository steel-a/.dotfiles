#!/bin/sh

# Lê as variáveis do arquivo
CONFIG_FILE="$HOME/.secrets/config.txt"
if [ -f "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
else
    echo "Arquivo de configuração '$CONFIG_FILE' não encontrado!"
    exit 1
fi

# Processo principal
killall -q hyprpaper 
hyprpaper &
$HOME/.config/pywal/venv/bin/wal -i "$CAMINHO_LOCAL.wallpaper.jpg"
ln -sf "$HOME/.cache/wal/colors-waybar.css" "$HOME/.config/waybar/colors-waybar.css"
source "$HOME/.cache/wal/colors.sh"
$HOME/.config/hypr/update_tmux_colors.sh

contador=1
while [ "$contador" -le 10 ]; do
    contador=$((contador + 1))

    # Conecta via SSH e lista os arquivos de imagem na pasta remota
    ARQUIVO=$(ssh -p "$PORTA" "$SERVIDOR" "ls $CAMINHO_REMOTO | sort -R | head -n 1")

    # Verifica se foi selecionado um arquivo
    if [ -z "$ARQUIVO" ]; then
        echo "Nenhum arquivo encontrado na pasta remota."
        sleep 20
        continue
    fi

    # Baixa o arquivo selecionado para o diretório local com o nome .wallpaper.jpg
    scp -P "$PORTA" "$SERVIDOR:$CAMINHO_REMOTO$ARQUIVO" "$CAMINHO_LOCAL.wallpaper.jpg"

    # Mensagem de confirmação
    if [ $? -eq 0 ]; then
        echo "Arquivo '$ARQUIVO' baixado como .wallpaper.jpg com sucesso!"
        exit 0
    else
        echo "Houve um erro ao baixar o arquivo."
        sleep 20
        continue
    fi
done

