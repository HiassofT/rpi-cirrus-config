# input and output interface/mixer definitions

# I2S interface RPi-WM5102 base name
rpi_if="AIF1"
rpi_in_if="${rpi_if}TX"
rpi_out_if="${rpi_if}RX"

# left+right mixer names
rpi_in_signals="${rpi_in_if}1 ${rpi_in_if}2"
rpi_out_signals="${rpi_out_if}1 ${rpi_out_if}2"

# I2S interface WM5102-WM8804 base name
spdif_if="AIF2"
spdif_in_if="${spdif_if}RX"
spdif_out_if="${spdif_if}TX"

# left+right mixer names
spdif_in_signals="${spdif_in_if}1 ${spdif_in_if}2"
spdif_out_signals="${spdif_out_if}1 ${spdif_out_if}2"

# input base names
headset_in="IN1"
dmic_in="IN2"
line_in="IN3"

# left+right mixer names (headset input is mono, connected to R)
headset_in_signal="${headset_in}R"
headset_in_signals="${headset_in_signal} ${headset_in_signal}"
dmic_in_signals="${dmic_in}L ${dmic_in}R"
line_in_signals="${line_in}L ${line_in}R"

# output base names
headset_out="HPOUT1"
line_out="HPOUT2"
speaker_out="SPKOUT"

headset_out_signals="${headset_out}L ${headset_out}R"
line_out_signals="${line_out}L ${line_out}R"
speaker_out_signals="${speaker_out}L ${speaker_out}R"

# low/high pass filter
filter_signals="LHPF1 LHPF2"
filter2_signals="LHPF3 LHPF4"

mixer() {
	amixer -q -c RPiCirrus cset name="$1" "$2"
}

# args: LEFT_MIXER RIGHT_MIXER LEFT_SRC RIGHT_SRC [ VOLUME [ INPUT ] ]
set_mixer() {
	# default input is 1, default volume 32 (0dB)
	local VOLUME="${5:-32}"
	local INPUT="${6:-1}"

	mixer "$1 Input $INPUT" "$3"
	mixer "$2 Input $INPUT" "$4"
	mixer "$1 Input $INPUT Volume" "$VOLUME"
	mixer "$2 Input $INPUT Volume" "$VOLUME"
}

# args: LEFT_MIXER RIGHT_MIXER LEFT_SRC RIGHT_SRC [ VOLUME ]
set_all_mixers() {
	local INP
	for INP in 1 2 3 4 ; do
		set_mixer "$1" "$2" "$3" "$4" "${5:-32}" "$INP"
	done
}

reset_rpi_in() {
	set_all_mixers $rpi_in_signals None None 32
}

reset_spdif_out() {
	set_all_mixers $spdif_out_signals None None 32
}

reset_headset_out() {
	mixer "${headset_out} Digital Switch" off
	mixer "${headset_out} Digital Volume" 128
	set_all_mixers $headset_out_signals None None 32
}

reset_line_out() {
	mixer "${line_out} Digital Switch" off
	mixer "${line_out} Digital Volume" 128
	set_all_mixers $line_out_signals None None 32
}

reset_speaker_out() {
	mixer "Speaker Digital Switch" off
	mixer "Speaker Digital Volume" 128
	set_all_mixers $speaker_out_signals None None 32
}

reset_filter() {
	mixer "LHPF1 Coefficients" "0,0"
	mixer "LHPF2 Coefficients" "0,0"
	set_all_mixers $filter_signals None None 32
}

reset_filter2() {
	mixer "LHPF3 Coefficients" "0,0"
	mixer "LHPF4 Coefficients" "0,0"
	set_all_mixers $filter2_signals None None 32
}

reset_line_in() {
	mixer "${line_in}L Digital Volume" 128
	mixer "${line_in}R Digital Volume" 128
	mixer "${line_in}L Volume" 0
	mixer "${line_in}R Volume" 0
	mixer "${line_in} High Performance Switch" off
	mixer "Line Input Micbias" off
}

reset_headset_in() {
	mixer "${headset_in_signal} Digital Volume" 128
	mixer "${headset_in_signal} Volume" 0
	mixer "${headset_in} High Performance Switch" off
}

reset_dmic_in() {
	mixer "${dmic_in}L Digital Volume" 128
	mixer "${dmic_in}R Digital Volume" 128
	mixer "${dmic_in}L Volume" 0
	mixer "${dmic_in}R Volume" 0
	mixer "${dmic_in} High Performance Switch" off
}

# reset all settings to default (off)
reset_rpi_cirrus() {
	# reset output mixers and filters
	reset_rpi_in
	reset_spdif_out
	reset_line_out
	reset_headset_out
	reset_speaker_out
	reset_filter
	reset_filter2

	# reset input signals:
	reset_line_in
	reset_headset_in
	reset_dmic_in

	# disable samplerate limiting
	mixer "Min Sample Rate" off
	mixer "Max Sample Rate" off

	# set WM8804 S/PDIF output source to WM5102
	mixer "Tx Source" AIF
}

# args: LEFT_SRC RIGHT_SRC [ VOLUME [ INPUT_NUM ] ]
setup_spdif_out() {
	# Limit samplerates to 32kHz-192kHz
	mixer "Min Sample Rate" 32kHz

	# set WM8804 S/PDIF output source to WM5102
	mixer "Tx Source" AIF

	set_mixer $spdif_out_signals "$@"
}

# args: LEFT_SRC RIGHT_SRC [ VOLUME [ INPUT_NUM ] ]
setup_line_out() {
	# mute Line Out
	mixer "${line_out} Digital Switch" off

	set_mixer $line_out_signals "$@"

	# unmute Line Out
	mixer "${line_out} Digital Switch" on
}

# args: LEFT_SRC RIGHT_SRC [ VOLUME [ INPUT_NUM ] ]
setup_headset_out() {
	# mute Line Out
	mixer "${headset_out} Digital Switch" off

	# route RPi I2S output to Headset Out
	set_mixer $headset_out_signals "$@"

	# unmute Line Out
	mixer "${headset_out} Digital Switch" on
}

# args: LEFT_SRC RIGHT_SRC [ VOLUME [ INPUT_NUM ] ]
setup_speaker_out() {
	# mute Speaker out
	mixer "Speaker Digital Switch" off

	# route RPi I2S output to Speaker Out
	set_mixer $speaker_out_signals "$@"

	# unmute Speaker out
	mixer "Speaker Digital Switch" on
}

# args: INPUT_MIXER [ VOLUME [ DIGITAL_VOLUME ] ]
setup_input() {
	# default volumes are 0dB
	mixer "${1} Volume" "${2:-0}"
	mixer "${1} Digital Volume" "${3:-128}"
}

# args: INPUT_NAME [ VOLUME [ DIGITAL_VOLUME ] ]
setup_input_stereo() {
	local INPUT_NAME="$1"
	shift
	setup_input "${INPUT_NAME}L" "$@"
	setup_input "${INPUT_NAME}R" "$@"
}

# args: [ VOLUME [ DIGITAL_VOLUME ] ]
setup_line_in() {
	# better THD in normal mode vs lower noise floor in high performance
	mixer "${line_in} High Performance Switch" on

	setup_input_stereo "${line_in}" "$@"
}

# args: [ VOLUME [ DIGITAL_VOLUME ] ]
setup_dmic_in() {
	setup_input_stereo "${dmic_in}" "$@"
}

# args: [ VOLUME [ DIGITAL_VOLUME ] ]
setup_headset_in() {
	setup_input "${headset_in_signal}" "$@"
}

# args: MODE COEFFICIENTS
setup_filter() {
	mixer "LHPF1 Mode" "$1"
	mixer "LHPF2 Mode" "$1"
	mixer "LHPF1 Coefficients" "$2"
	mixer "LHPF2 Coefficients" "$2"
}

# args: LEFT_SRC RIGHT_SRC [ COEFFICIENTS [ INPUT_VOLUME [ INPUT_NUM ] ] ]
setup_high_pass_filter() {
	# configure high-pass filter to remove DC for recording
	setup_filter "High-pass" "${3:-240,3}"
	local LEFT_SRC="$1"
	local RIGHT_SRC="$2"
	if [ $# -ge 3 ] ; then
		shift 3
	else
		shift 2
	fi
	set_mixer $filter_signals "$LEFT_SRC" "$RIGHT_SRC" "$@"
}

# helper functions corresponding to use-case scripts

reset_paths() {
	reset_rpi_cirrus
}

playback_to_spdif() {
	reset_spdif_out
	setup_spdif_out $rpi_out_signals
}

# args: [ VOLUME ]
playback_to_lineout() {
	reset_line_out
	mixer "${line_out} Digital Volume" "${1:-128}"
	setup_line_out $rpi_out_signals
}

# args: [ VOLUME ]
playback_to_headset() {
# use defauk path gain of -6dB for safety. ie max 0.5Vrms output level.
	reset_headset_out
	mixer "${headset_out} Digital Volume" "${1:-116}"
	setup_headset_out $rpi_out_signals
}

# args: [ VOLUME ]
playback_to_speakers() {
	reset_speaker_out
	mixer "Speaker Digital Volume" "${1:-128}"
	setup_speaker_out $rpi_out_signals
}

# args: [ VOLUME [ DIGITAL_VOLUME ] ]
record_from_linein() {
	reset_line_in
	reset_filter
	reset_rpi_in

	# better THD in normal mode vs lower noise floor in high performance
	mixer "${line_in} High Performance Switch" on

	# default input gain +8dB
	setup_line_in "${1:-8}" "${2:-128}"

	# route input through high pass filter to remove DC
	setup_high_pass_filter $line_in_signals
	set_mixer $rpi_in_signals $filter_signals
}

# args: [ VOLUME [ DIGITAL_VOLUME ] ]
record_from_linein_micbias() {
	reset_line_in
	reset_filter
	reset_rpi_in

	mixer "Line Input Micbias" on

	# better THD in normal mode vs lower noise floor in high performance
	mixer "${line_in} High Performance Switch" on

	# default input gain +8dB
	setup_line_in "${1:-8}" "${2:-128}"

	# route input through high pass filter to remove DC
	setup_high_pass_filter $line_in_signals
	set_mixer $rpi_in_signals $filter_signals
}

# args: [ VOLUME [ DIGITAL_VOLUME ] ]
record_from_dmic() {
	reset_dmic_in
	reset_filter
	reset_rpi_in

	# default input gain 0dB and digital gain -6dB
	setup_dmic_in "${1:-0}" "${2:-116}"

	# route input through high pass filter to remove DC
	setup_high_pass_filter $dmic_in_signals
	set_mixer $rpi_in_signals $filter_signals
}

# args: [ VOLUME [ DIGITAL_VOLUME ] ]
record_from_headset() {
	reset_headset_in
	reset_filter
	reset_rpi_in

	# default input gain +20dB
	setup_headset_in "${1:-20}" "${2:-128}"

	# route input through high pass filter to remove DC
	setup_high_pass_filter $headset_in_signals
	set_mixer $rpi_in_signals $filter_signals
}

record_from_spdif() {
	reset_rpi_in

	mixer "Min Sample Rate" 32kHz
	set_mixer $rpi_in_signals $spdif_in_signals
}
