#!/bin/sh
# Rebuild LispM Nerd Font variants with the official nerdfonts/patcher image.
# Note: do NOT pass `-u $(id -u)` to docker; FontForge's save fails under an unknown uid.
set -e
cd "$(dirname "$0")"
UPSTREAM_COMMIT=e1ea577660f54721e00b86cb988232b3d7a17a62
if [ ! -d src/LispM-Font ]; then
  git clone https://github.com/unjordy/LispM-Font.git src/LispM-Font
  git -C src/LispM-Font checkout -q "$UPSTREAM_COMMIT"
fi
rm -rf work/in && mkdir -p work/in out
cp src/LispM-Font/LispM-Monospace.ttf work/in/
for variant in --mono ""; do
  docker run --rm -v "$PWD/work/in:/in" -v "$PWD/out:/out" \
    --entrypoint fontforge nerdfonts/patcher \
    -script /nerd/font-patcher -out /out --complete $variant /in/LispM-Monospace.ttf
done
rm -rf work/in
if [ "$1" = "--install" ]; then
  mkdir -p ~/.local/share/fonts/LispMNerdFont
  cp out/*.ttf ~/.local/share/fonts/LispMNerdFont/
  fc-cache -f ~/.local/share/fonts
fi
ls -l out
