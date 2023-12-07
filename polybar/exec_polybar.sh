#! /bin/bash

polybar-msg cmd quit

polybar -r mainbar 2>&1 | tee -a /tmp/polybar.log & disown
