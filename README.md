# Cirrus Logic Audio Card config scripts

Config files and scripts needed to setup the Cirrus Logic Audio Card

## rpicirrusctl.sh

Shell script to setup the mixer for common tasks:

* `rpicirrusctl.sh reset-paths` reset mixer, disable all inputs and outputs
* `rpicirrusctl.sh playback-to ...` configure for audio output
* `rpicirrusctl.sh record-from ...` configure for audio recording
* `rpicirrusctl.sh listen ...` route input signals directly to output

## alsa

* [`RPiCirrus.conf`](alsa/RPiCirrus.conf) ALSA card configuration for IEC958 (S/PDIF) output. Copy this file to `/usr/share/alsa/cards` to get S/PDIF AC3 and DTS passthrough in audio and video player applications like Kodi.
