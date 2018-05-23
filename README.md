# Cirrus Logic Audio Card config scripts

## Supported devices:

* [Wolfson Audio Card](http://www.element14.com/wolfson) for Raspberry Pi B,
* [Cirrus Logic Audio Card](http://www.element14.com/cirruslogic_ac) for Raspberry Pi B+/A+/2

## rpicirrusctl.sh

Shell script to setup the mixer for common tasks:

* `rpicirrusctl.sh reset-paths` reset mixer, disable all inputs and outputs
* `rpicirrusctl.sh playback-to ...` configure for audio output
* `rpicirrusctl.sh record-from ...` configure for audio recording
* `rpicirrusctl.sh listen ...` route input signals directly to output

## ALSA

* [`RPiCirrus.conf`](alsa/RPiCirrus.conf) ALSA card configuration for IEC958 (S/PDiF) output. Copy this file to `/usr/share/alsa/cards` to get S/PDiF AC3 and DTS passthrough in audio and video player applications like *Kodi*.
