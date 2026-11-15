# LispM Nerd Font

A [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)–patched build of the
[Lisp Machine console font](https://github.com/unjordy/LispM-Font) (the CPTFONT
used on MIT / Symbolics / TI Lisp Machine consoles), plus instructions for using
it as the default font in [Ghostty](https://ghostty.org).

Prebuilt fonts are in `out/`:

| File | Family name | Notes |
| --- | --- | --- |
| `LispMMonospaceNerdFontMono-Regular.ttf` | `LispMMonospace Nerd Font Mono` | Icons squeezed into a single cell. Recommended for terminals. |
| `LispMMonospaceNerdFont-Regular.ttf` | `LispMMonospace Nerd Font` | Icons may be wider than one cell. |

Both include the complete Nerd Fonts glyph set (`--complete`), built with
`nerdfonts/patcher` 4.27.3 from upstream commit `e1ea577`.

## Setup (Linux)

### 1. Install the font

```sh
mkdir -p ~/.local/share/fonts/LispMNerdFont
cp out/*.ttf ~/.local/share/fonts/LispMNerdFont/
fc-cache -f ~/.local/share/fonts
```

Check it is visible:

```sh
fc-list | grep -i "LispMMonospace Nerd Font"
ghostty +list-fonts | grep -i lispm
```

(On macOS, double-click the `.ttf` files and click "Install Font" instead.)

### 2. Configure Ghostty

Add to `~/.config/ghostty/config.ghostty` (or `~/.config/ghostty/config` on
older Ghostty versions):

```
font-family = "LispMMonospace Nerd Font Mono"
font-size = 13
```

The font was designed for 13pt; that size looks most authentic. Validate with:

```sh
ghostty +validate-config
```

### 3. Restart Ghostty fully

Ghostty on Linux usually runs as a single background instance (often started by
the `app-com.mitchellh.ghostty.service` systemd user unit). That process reads
the list of installed fonts **only at startup**, so a newly installed font is
not picked up by opening a new window or by reloading the config
(Ctrl+Shift+,). Close all Ghostty windows, then:

```sh
systemctl --user restart app-com.mitchellh.ghostty.service
# or, if not using the systemd unit:
pkill ghostty
```

New windows will now use the LispM font. Later config-only changes (like
`font-size`) do apply with Ctrl+Shift+,.

## Rebuilding from source

Requires Docker and git.

```sh
./build.sh            # writes both variants to out/
./build.sh --install  # also installs them to ~/.local/share/fonts
```

The script clones the upstream font into `src/` (ignored by git) at a pinned
commit and runs the official `nerdfonts/patcher` image.

To do it by hand:

```sh
git clone https://github.com/unjordy/LispM-Font.git src/LispM-Font
mkdir -p work/in out && cp src/LispM-Font/LispM-Monospace.ttf work/in/
docker run --rm -v "$PWD/work/in:/in" -v "$PWD/out:/out" \
  --entrypoint fontforge nerdfonts/patcher \
  -script /nerd/font-patcher -out /out --complete --mono /in/LispM-Monospace.ttf
```

Drop `--mono` to build the wide-icon variant.

**Gotcha:** don't run the container with `-u $(id -u):$(id -g)`. FontForge
fails at the save step with `OSError: Font generation failed` when the uid
has no passwd entry in the container.

## License

The LispM font is © 1980 Massachusetts Institute of Technology, distributed
under the BSD-style license in [`LICENSE`](LICENSE). The added icon glyphs
come from the Nerd Fonts project and its upstream icon sets, each under
its own license; see the
[Nerd Fonts license notes](https://github.com/ryanoasis/nerd-fonts/blob/master/license-audit.md).
