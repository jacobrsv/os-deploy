#!/bin/ash
# Script demonstrating colored output in ash using printf and ANSI escape codes

# Define color variables for readability (using printf's octal format \033)
RESET='\033[0m'       # Reset all attributes

# Foreground Colors (Text)
FG_BLACK='\033[0;30m'
FG_RED='\033[0;31m'
FG_GREEN='\033[0;32m'
FG_YELLOW='\033[0;33m'
FG_BLUE='\033[0;34m'
FG_MAGENTA='\033[0;35m'
FG_CYAN='\033[0;36m'
FG_WHITE='\033[0;37m'

# Background Colors
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

# Styles
BOLD='\033[1m'
UNDERLINE='\033[4m'
# Note: Not all styles are supported by all terminals

# --- Print examples using printf ---

printf "=== Standard Colors ===\n"
printf "${FG_RED}This is red text.${RESET}\n"
printf "${FG_GREEN}This is green text.${RESET}\n"
printf "${FG_YELLOW}This is yellow text.${RESET}\n"
printf "${FG_BLUE}This is blue text.${RESET}\n"
printf "${FG_MAGENTA}This is magenta text.${RESET}\n"
printf "${FG_CYAN}This is cyan text.${RESET}\n"
printf "${FG_WHITE}This is white text.${RESET}\n"
printf "This text is normal (default color).\n"

printf "\n=== Styles ===\n"
printf "${BOLD}This is bold text.${RESET}\n"
printf "${UNDERLINE}This is underlined text.${RESET}\n"
printf "${BOLD}${FG_BLUE}This is bold blue text.${RESET}\n" # Combining style and color

printf "\n=== Background Colors ===\n"
printf "${BG_RED}${FG_WHITE}White text on red background.${RESET}\n"
printf "${BG_GREEN}${FG_BLACK}Black text on green background.${RESET}\n"
printf "${BG_YELLOW}${BOLD}${FG_BLUE}Bold blue text on yellow background.${RESET}\n"

printf "\n=== Mixed Example ===\n"
printf "Status: ${BOLD}${FG_GREEN}OK${RESET} | ${BOLD}${FG_RED}ERROR${RESET} | ${FG_YELLOW}Warning${RESET}\n"

exit 0
