#!/usr/bin/env bashio
set +u

WAIT_PIDS=()
ADDON_PATH='/share/frp'
CONFIG_PATH='/share/frp/frpc.ini'

function stop_frpc() {
    bashio::log.info "Shutdown frpc client"
    kill -15 "${WAIT_PIDS[@]}"
    wait "${WAIT_PIDS[@]}"
}

function logger() {
    local log_file=$1
    tail -f -F -q -n 0 $log_file | while read output
    do
        bashio::log.info $output
    done
}

bashio::log.info "Starting frp client"

mkdir -p $ADDON_PATH || bashio::exit.nok "Could not create ${ADDON_PATH} folder"

if ! bashio::fs.file_exists $CONFIG_PATH; then
    bashio::fatal "Can't find ${CONFIG_PATH}"
    bashio::exit.nok
fi

log_file=$(sed -n "/^[ \t]*\[common\]/,/\[/s/^[ \t]*log_file[ \t]*=[ \t]*//p" ${CONFIG_PATH})

if [[ ! -n "${log_file}" ]]; then
    bashio::log.info 'Please specify a path to log file in config file'
    bashio::exit.nok
fi

cd /usr/src
./frpc -c $CONFIG_PATH & logger $log_file & WAIT_PIDS+=($!)


trap "stop_frpc" SIGTERM SIGHUP

# Wait and hold Add-on running
wait "${WAIT_PIDS[@]}"