#!/bin/sh

MYDIR=$(dirname "$0")
. "${MYDIR}/rpi-cirrus-functions.sh"

usage() {
	echo "usage: $0 output input [mixer-num]"
	echo "    output: line, headset, spdif, speaker"
	echo "    input: line, headset, spdif, dmic"
	echo "    mixer-num: 1-4, default is 2"
	exit 0
}

# check parameters
if [ $# -lt 2 -o $# -gt 3 ] ; then
	usage
fi

LISTEN_OUT="$1"
LISTEN_IN="$2"
MIXER_NUM="${3:-2}"

case "$LISTEN_IN" in
    line|headset|spdif|dmic)
	;;
    *)
	usage
	;;
esac

case "$LISTEN_OUT" in
    line|headset|spdif|speaker)
	;;
    *)
	usage
	;;
esac

case "$MIXER_NUM" in
    1|2|3|4)
	;;
    *)
	usage
	;;
esac

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
	# use defauk path gain of -6dB for safety
	mixer "${headset_out} Digital Volume" 116
	set_mixer $headset_out_signals $IN_SIGNALS 32 $MIXER_NUM
	mixer "${headset_out} Digital Switch" on
	;;
    spdif)
	mixer "Tx Source" AIF
	set_mixer $spdif_out_signals $IN_SIGNALS 32 $MIXER_NUM
	;;
    speaker)
	# use defauk path gain of -6dB
	mixer "Speaker Digital Volume" "${1:-116}"
	set_mixer $speaker_out_signals $IN_SIGNALS 32 $MIXER_NUM
	mixer "Speaker Digital Switch" on
	;;
esac


