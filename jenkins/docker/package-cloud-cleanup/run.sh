#!/bin/bash

cd $(dirname "$0")

apt-get update
apt-get install -y python python-pip git

pip install -r requirements.txt
python main.py ${CONFIG_FILE}
