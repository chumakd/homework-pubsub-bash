### pubsub common functions

# colors
if [[ -t 2 && -n $TERM && $TERM != dumb ]] ; then
    readonly NC="$(tput sgr0)" # No Color
    readonly LightRed="$(tput bold ; tput setaf 1)"
    readonly Yellow="$(tput bold ; tput setaf 3)"
    readonly Green="$(tput setaf 2)"
    readonly White="$(tput bold ; tput setaf 7)"
fi

_help() {
    [[ $1 == stdout ]] && usage || {
        usage >&2
        exit 2
    }
    exit
}

debug() {
    if [[ $1 == '-n' ]] ; then
        local opts=$1 ; shift
    fi
    ! $verbose || echo $opts -e "$PROG_NAME $Green[debug]$NC ${FUNCNAME[1]}(): $*" >&2
}

info() {
    echo -e "--> $White${*}$NC" >&2
}

warn() {
    echo -e "$PROG_NAME $Yellow[warn]$NC $*" >&2
}

die() {
    echo -e "$PROG_NAME $LightRed[err]$NC $*" >&2
    exit 1
}

show_unread_docker_logs() {
    local container=${1?show_unread_docker_logs() requires 'container' argument}

    [[ -n $DOCKER_LOGS_COUNTER ]] ||
        die 'Internal error, DOCKER_LOGS_COUNTER variable must be defined'

    [[ -s $DOCKER_LOGS_COUNTER ]] || echo 0 > "$DOCKER_LOGS_COUNTER"

    local start_line=$(( 1 + $(cat $DOCKER_LOGS_COUNTER) ))
    docker logs $container |& tee >(wc -l > "$DOCKER_LOGS_COUNTER") | tail -n+$start_line
}
