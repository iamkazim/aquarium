#!/bin/bash

if [ -d "./data" ]; then
   DATA_DIR=data
elif [ -d "./docker" ]; then
   DATA_DIR=./docker
else
   echo "Data directory not found, bailing out"
   exit 1
fi

MIRROR_CMD='./mirror.sh'
DUMP_FILE='biofab_production.dump'
if [ $# -gt 0 ]; then
   if [ $1 == "nursery" ]; then
       MIRROR_CMD='./mirror_nursery.sh'
       DUMP_FILE='nursery_production.dump'
   fi
fi

PEM_FILE=erics-key.pem
SERVER=ubuntu@52.27.43.242
echo -e "\033[95mDumping data from BIOFAB on AWS machine \033[39m"
ssh -i "$PEM_FILE" $SERVER "$MIRROR_CMD"

if [ $? -ne 0 ]; then
   echo "dump failed"
   exit
fi

echo -e "\033[95mCopying dump to local machine \033[39m"
scp -i "$PEM_FILE" $SERVER:$DUMP_FILE ./$DATA_DIR/mysql_init/dump.sql

echo -e "\033[95mDeleting dump on AWS machine \033[39m"
ssh -i "$PEM_FILE" $SERVER "rm $DUMP_FILE"

echo -e "\033[95mRemoving old local database \033[39m"
sudo rm -rf ./$DATA_DIR/db/*

echo -e "\033[95mDatabase copy finished\033[39m"
