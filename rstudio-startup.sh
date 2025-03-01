#!/bin/bash

rserverport="${R_SERVER_PORT:-8787}"
if [[ -t 1 ]]; then
  GREEN='\033[0;32m'
  NOCOLOR='\033[0m'
else
  GREEN=''
  NOCOLOR=''
fi

# Create R lib directory
if [ ! -d "$HOME/R/APPTAINER/h2-rstudio_${R_VER}" ]; then
    mkdir -p "$HOME/R/APPTAINER/h2-rstudio_${R_VER}"
fi

# Check if there are any arguments
echo "test $*"
echo "test2 $@"
echo "test3 $1"
echo "test4 $#"
echo "Number of args: $#"
echo "Args as string: $*"
echo "Args individually:"
for arg in "$@"; do
  echo "$arg"
done

if [ -z "$*" ]; then

  checkport=$(ss -tulpn | grep ":${rserverport}")
  while [ -n "$checkport" ]; do
    rserverport=$((rserverport + 1))
    checkport=$(ss -tulpn | grep ":${rserverport}")
  done

  export PORT=$rserverport
  export HOST="$(hostname)"
  export USER="$(whoami)"
  export PASSWORD="$(< /dev/urandom tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)"    

  echo
  echo "This is the Rstudio server container running R ${R_VER} from Rocker"
  echo
  echo "This is a separate R version from the rest of Hoffman2"
  echo "When you install libraries from this Rstudio/R, they will be in ~/R/APPTAINER/h2-rstudio_${R_VER}"
  echo

  # Use printf for colorized lines:
  printf "Your Rstudio server is running on: ${GREEN}%s${NOCOLOR}\n" "${HOST}"
  printf "It is running on PORT: ${GREEN}%s${NOCOLOR}\n" "${PORT}"
  echo

  echo "Open a SSH tunnel on your local computer by running:"
  printf "${GREEN}ssh -N -L %s:%s:%s %s@hoffman2.idre.ucla.edu${NOCOLOR}\n" \
         "${PORT}" "${HOST}" "${PORT}" "${USER}"
  echo

  printf "Then open your web browser to ${GREEN}http://localhost:%s${NOCOLOR}\n" "${PORT}"
  echo

  printf "Your Rstudio USERNAME is: ${GREEN}%s${NOCOLOR}\n" "${USER}"
  printf "Your Rstudio PASSWORD is: ${GREEN}%s${NOCOLOR}\n" "${PASSWORD}"
  echo "Please run [CTRL-C] on this process to exit Rstudio"
  echo

  rserver \
    --server-user="${USER}" \
    --www-port="${PORT}" \
    --auth-none=0 \
    --auth-pam-helper-path=pam-helper
else
  export R_LIBS_USER="$HOME/R/APPTAINER/h2-rstudio_${R_VER}"
  exec "$@"
fi
