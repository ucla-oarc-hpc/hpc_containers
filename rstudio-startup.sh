rserverport="${R_SERVER_PORT:-8787}"
GREEN='\033[0;32m'
NOCOLOR='\033[0m'
checkport=`ss -tulpn | grep ":${rserverport}"`
while [ ! -z "$checkport" ]
do
   rserverport=`echo ${rserverport} + 1 | bc`
   echo $rserverport
   checkport=`ss -tulpn | grep ":${rserverport}"`
done
export PORT=$rserverport
export HOST=`hostname`

export USER=`whoami`
export PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

echo  "\n\nThis is the Rstudio server container running R ${R_VER} from Rocker"
echo ""
echo "This is a separate R version from the rest of Hoffman2"
echo "When you install libraries from this Rstudio/R, they will be in ~/R/APPTAINER/h2-rstudio_${R_VER}"
echo ""
echo  -e "Your Rstudio server is running on: ${GREEN} ${HOST} ${NOCOLOR}"
echo  -e "It is running on PORT: ${GREEN} ${PORT} ${NOCOLOR}"
echo ""
echo "Open a SSH tunnel on your local computer by running:"
echo  -e "${GREEN} ssh -N -L ${PORT}:${HOST}:${PORT} ${USER}@hoffman2.idre.ucla.edu ${NOCOLOR}"
echo ""
echo  -e "Then open your web browser to ${GREEN} http://localhost:${PORT} ${NOCOLOR}"
echo ""
echo -e "Your Rstudio USERNAME is: ${GREEN} ${USER} ${NOCOLOR}"
echo -e "Your Rstudio PASSWORD is: ${GREEN} ${PASSWORD} ${NOCOLOR}"
echo "Please run [CTRL-C] on this process to exit Rstudio"
echo ""
rserver --server-user=${USER} --www-port=${PORT} --auth-none=0 --auth-pam-helper-path=pam-helper
