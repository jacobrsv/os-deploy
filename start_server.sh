#!/bin/bash
###############################################################################
######          KEA IT-Teknolog, 4. semester afsluttende projekt         ######
###                               OS-Deploy                                 ###
######                      Jacob Rusch Svendsen                         ######
###############################################################################
caddy run &
cd app
.venv/bin/python app.py &
wait