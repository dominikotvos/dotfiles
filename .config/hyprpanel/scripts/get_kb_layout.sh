#!/bin/bash

layout=$(qdbus org.fcitx.Fcitx5 /controller org.fcitx.Fcitx.Controller1.CurrentInputMethod | tr -d '"')

case "$layout" in
    "hangul")
        echo "KR"
        ;;
    "keyboard-us")
        echo "US"
        ;;
    "keyboard-hu")
        echo "HU"
        ;;
    *)
        # so that its not empty before typing for the first time after boot
        echo "US"
        ;;
esac
