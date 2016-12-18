# Cirrus Logic Audio Card config scripts

Config files and scripts needed to setup the Cirrus Logic Audio Card

## mixer-scripts

Shell scripts to setup the mixer for common tasks:

* `Reset_paths.sh` reset mixer, disable all inputs and outputs
* `Playback_to_...` configure for audio output
* `Record_from_...` configure for audio recording
* `Cirrus_listen.sh` route input signals directly to output
* `rpi-cirrus-functions.sh` common functions used to simplify above scripts

## alsa

* `RPi-Cirrus.conf` ALSA card configuration for IEC958 (S/PDIF) output. Copy this file to `/usr/share/alsa/cards` to get S/PDIF AC3 and DTS passthrough in audio and video player applications like Kodi.

