#!/bin/bash
#
# Copyright Innovasoft  All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Salir al primer error
set -e

# Esto es para no tener que reescribir las rutas para los usuarios de que usan Git Bash en Windows
export MSYS_NO_PATHCONV=1
starttime=$(date +%s)
LANGUAGE=${1:-"golang"}
#CC_SRC_PATH=github.com/fabcar/go   
CC_SRC_PATH=github.com/marbles/go #Cambie el anterior a este para hacer unas pruebas de directorio, si da problemas lo restituyo
if [ "$LANGUAGE" = "node" -o "$LANGUAGE" = "NODE" ]; then
	#CC_SRC_PATH=/opt/gopath/src/github.com/fabcar/node
	CC_SRC_PATH=/opt/gopath/src/github.com/marbles/node   #Lo mismo que el anterior
fi

# Limpiar el directorio de claves
rm -rf ./hfc-key-store  

# Aqui lanzo toda la configuracion de la red Blockchain, se crea un canal y se une un par a ese canal
./start.sh

# Ahora se lanza el contenedor del CLI para poder instalar e instanciar el chaincode
# y poblar la red con datos
docker-compose -f ./docker-compose.yml up -d cli

sleep 10

printf "\nTiempo hasta el establecimiento de la red: $(($(date +%s) - starttime)) segundos ...\n\n\n"
printf "Instalando paquetes necesarios 'npm install'\n"
npm install

printf "Creando Administrador inicial\n\n"

node enrollAdmin.js
node registerUser.js

cd ../scripts

node  install_chaincode.js  

sleep 20

node instantiate_chaincode.js

printf "\nTiempo total de configuracion de la red y puesta en marcha: $(($(date +%s) - starttime)) segundos ...\n\n\n"

cd ..

printf "Iniciando aplicacion \n\n"

gulp marbles_local
