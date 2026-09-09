#!/bin/bash

#criar diretório na aplicação
mkdir -p /opt/sync-roteirizador

#injeta o codigo python na aplicação
cat << 'EOF' > /opt/sync-roteirizador/app.py
import time, random, logging
logging.basicConfig(filename='/var/log/sync-roteirizador.log', level=logging.INFO, format=('%(asctime)s - %(levelname)s - %(message)s'))
caminhoes = ['CAM-101', 'CAM-204', 'CAM-309', 'CAM-999']
while True:
    caminhao = random.choice(caminhoes)
    if random.random() < 0.05:
        logging.error(f"Falha ao sincronizar rota do {caminhao}. Timeout")
    else:
        logging.info(f"[{caminhao}] Posição atualizada. Status: OK")
    time.sleep(random.uniform(0.5, 2.0))
EOF

# Injeta a configuração no systemd
cat << 'EOF' > /etc/systemd/system/sync-roteirizador.service
[Unit]
Description=Daemon de Sincronizacao de logistica
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/sync-roteirizador/app.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

#Recarrega systemd, habilita o serviço e inicia o serviço
systemctl daemon-reload
systemctl enable --now sync-roteirizador
