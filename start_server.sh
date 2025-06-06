#!/bin/bash
###############################################################################
######          KEA IT-Teknolog, 4. semester afsluttende projekt         ######
###                               OS-Deploy                                 ###
######                      Jacob Rusch Svendsen                         ######
###############################################################################
journalctl _EXE=/usr/bin/dnsmasq -f &
caddy run | jq -r '"\(.msg) \(.request.method) \(.request.uri) \(.request.remote_ip)"' &
cd app
.venv/bin/python app.py &
chromium --incognito "http://osdeploy:8000" > /dev/null 2>&1 & 
wait
