#!/bin/bash
###############################################################################
######          KEA IT-Teknolog, 4. semester afsluttende projekt         ######
###                               OS-Deploy                                 ###
######                      Jacob Rusch Svendsen                         ######
###############################################################################
caddy run  &
cd app
.venv/bin/python app.py &
chromium --incognito "http://osdeploy:8000" > /dev/null 2>&1 & 
wait
