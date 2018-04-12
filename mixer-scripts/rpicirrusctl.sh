#!/bin/sh

SCRIPT_NAME="${0/*\//}"
SCRIPT_DIR=$(dirname "$0")
FN_SCRIPT=rpi-cirrus-functions.sh

echoerr() {
    echo "$@" 1>&2
}

# include rpi-cirrus-functions.sh
if [ -f /usr/share/rpi-cirrus/${FN_SCRIPT} ]; then
    . /usr/share/rpi-cirrus/${FN_SCRIPT}
elif [ -f  ${SCRIPT_DIR}/${FN_SCRIPT} ]; then
    . ${SCRIPT_DIR}/${FN_SCRIPT}
else
    echoerr "${SCRIPT_NAME}: Unable to find ${FN_SCRIPT} file"
    exit 1
fi

# playback-to

usage_playback_to() {
    echo "usage: ${SCRIPT_NAME} playback-to output|help"
    echo '    output: headset, line-out, spdif, speakers'
}

cmd_playback_to() {
    if [ $# -lt 1 ]; then
        usage_playback_to
        return 0
    fi
    
    local PLAYBACK_OUT="$1"
    shift

    case "${PLAYBACK_OUT}" in
        headset)
        playback_to_headset "$@"
        ;;

        line|line-out)
        playback_to_lineout "$@"
        ;;

        spdif)
        playback_to_spdif "$@"
        ;;

        speakers)
        playback_to_speakers "$@"
        ;;

        help)
        usage_playback_to
        ;;

        *)
        echoerr "${SCRIPT_NAME} playback-to: Unknown output - ${PLAYBACK_OUT}"
        return 1
        ;;
    esac
}

# record-from

usage_record_from() {
    echo "usage: ${SCRIPT_NAME} record-from input|help"
    echo '    input: dmic, mic, headset, line-in, line-in-micbias, spdif'
}

cmd_record_from() {
    if [ $# -lt 1 ]; then
        usage_record_from
        return 0
    fi
    
    local RECORD_IN="$1"
    shift

    case "${RECORD_IN}" in
        dmic)
        record_from_dmic "$@"
        ;;

        headset)
        record_from_headset "$@"
        ;;

        line|line-in)
        record_from_linein "$@"
        ;;

        line-micbias|line-in-micbias)
        record_from_linein_micbias "$@"
        ;;

        spdif)
        record_from_spdif "$@"
        ;;

        help)
        usage_record_from
        ;;

        *)
        echoerr "${SRCIPT_NAME} record-from: Unknown input - ${RECORD_IN}"
        return 1
        ;;
    esac
}

# reset-paths

usage_reset_paths() {
    echo "usage: ${SCRIPT_NAME} reset-paths [help]"
}

cmd_reset_paths() {
    if [ $# -lt 1 ]; then
        reset_paths
        return
    fi

    case $1 in
        help)
        usage_reset_paths
        ;;

        *)
        echoerr "{SRCIPT_NAME}reset-paths: Unknown parameter - $1"
        return 1
        ;;
    esac
}

# listen

usage_listen() {
    echo "usage: ${SRIPT_NAME} listen output input [mixer-num]"
    echo "    output: line, headset, spdif, speaker"
    echo "    input: line, headset, spdif, dmic"
    echo "    mixer-num: 1-4, default is 2"
}

cmd_listen() {
    if [ $# -lt 2 ]; then
        usage_listen
        return 0
    fi

    local LISTEN_OUT="$1"
    local LISTEN_IN="$2"
    local MIXER_NUM="${3:-2}"
    shift 3

    case "$LISTEN_IN" in
        line|headset|spdif|dmic)
        ;;

        *)
        echoerr "${SCRIPT_NAME} listen: invalid input - ${LISTEN_IN}"
        return 1
        ;;
    esac

    case "$LISTEN_OUT" in
        line|headset|spdif|speaker)
        ;;

        *)
        echoerr "${SCRIPT_NAME} listen: invalid output - ${LISTEN_OUT}"
        return 1
        ;;
    esac

    case "$MIXER_NUM" in
        1|2|3|4)
        ;;

        *)
        echoerr "${SCRIPT_NAME} listen: invalid mixer number - ${MIXER_NUM}"
        return 1
        ;;
    esac

    local IN_SIGNALS=''

    # setup input
    case "$LISTEN_IN" in
        line)
        IN_SIGNALS=$line_in_signals
        mixer "${line_in} High Performance Switch" on
        mixer "Line Input Micbias" off
        # default input gain +8dB
        setup_line_in 8 128
        ;;

        headset)
        IN_SIGNALS=$headset_in_signals
        # default input gain +20dB
        setup_headset_in 20 128
        ;;

        spdif)
        IN_SIGNALS=$spdif_in_signals
        ;;

        dmic)
        IN_SIGNALS=$dmic_in_signals
        # default input gain 0dB and digital gain -6dB
        setup_dmic_in 0 116
        ;;
    esac

    # setup output
    case "$LISTEN_OUT" in
        line)
        mixer "${line_out} Digital Volume" 128
        set_mixer $line_out_signals $IN_SIGNALS 32 $MIXER_NUM
        mixer "${line_out} Digital Switch" on
        ;;

        headset)
        # use default path gain of -6dB for safety
        mixer "${headset_out} Digital Volume" 116
        set_mixer $headset_out_signals $IN_SIGNALS 32 $MIXER_NUM
        mixer "${headset_out} Digital Switch" on
        ;;

        spdif)
        mixer "Tx Source" AIF
        set_mixer $spdif_out_signals $IN_SIGNALS 32 $MIXER_NUM
        ;;

        speaker)
        # use default path gain of -6dB
        mixer "Speaker Digital Volume" 116
        set_mixer $speaker_out_signals $IN_SIGNALS 32 $MIXER_NUM
        mixer "Speaker Digital Switch" on
        ;;
    esac
}

# rpicirrusctl

usage() {
    echo "usage: ${SCRIPT_NAME} command|help [...]"
    echo '    command: playback-to, record-from, reset-paths, listen'
}

mixer_query || {
    exit 2
}

# check parameters
if [ $# -lt 1 ]; then
    usage
    exit 0
fi

CMD=$1
shift

case "$CMD" in
    playback|playback-to)
    cmd_playback_to "$@"
    ;;

    record|record-from)
    cmd_record_from "$@"
    ;;

    reset|reset-paths)
    cmd_reset_paths "$@"
    ;;

    listen)
    cmd_listen "$@"
    ;;

    help)
    usage
    ;;

    *)
    echoerr "${SCRIPT_NAME}: Unknown command - ${CMD}"
    exit 1
    ;;
esac
