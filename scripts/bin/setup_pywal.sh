#!/bin/sh

# Verifica se a pasta ~/.config/pywal existe, caso contrário cria
if [ ! -d "$HOME/.config/pywal" ]; then
    echo "Criando a pasta ~/.config/pywal..."
    mkdir -p "$HOME/.config/pywal"
fi

# Verifica se a pasta ~/.config/pywal/venv existe, caso contrário cria o venv
if [ ! -d "$HOME/.config/pywal/venv" ]; then
    echo "Criando o ambiente virtual (venv) em ~/.config/pywal/venv..."
    python3 -m venv "$HOME/.config/pywal/venv"
    # Ativa o venv usando o comando source
    echo "Ativando o ambiente virtual..."
    source "$HOME/.config/pywal/venv/bin/activate"

    # Instala o pywal16 usando pip
    echo "Instalando o pywal16..."
    pip install pywal16

fi

echo "Processo concluído!"

