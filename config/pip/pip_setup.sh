#!/usr/bin/env bash

# python3 -m pip install --upgrade --force-reinstall pip \
# && pip3 install -r ./pip/requirements.txt
file_dir=$(dirname "$(readlink -f "${0}")")

pip install --upgrade --force-reinstall pip \
&& pip install --upgrade --ignore-installed -r "${file_dir}"/requirements.txt \


# install websocket
pip install websocket-client==1.8.0