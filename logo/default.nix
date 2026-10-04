{ lib, runCommand, nixos-icons, resvg, inter }:
let
  kz = import ./colors.nix;

  dark = [ "#415e9a" "#4a6baf" "#5277c3" ];
  light = [ "#699ad7" "#7eb1dd" "#7ebae4" ];

  recolor = from: to:
    lib.concatMapStringsSep " " (p: "-e 's/${p.fst}/${p.snd}/gI'") (lib.zipLists from to);

  sizes = [ 256 512 1024 ];
  render = name: lib.concatMapStringsSep "\n"
    (s: "resvg -w ${toString s} -h ${toString s} ${name}.svg ${name}-${toString s}.png")
    sizes;

  avatar = ''
    avatar() {
      cat <<EOF
    <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 1024 1024" width="1024" height="1024">
    $(sed -e '1{/^<?xml/d}' -e '0,/width="535"/s//x="41" y="41" width="942"/' -e '0,/height="535"/s//height="942"/' "$1")
    $2
    </svg>
    EOF
    }
  '';

  movedRibbon = ''
    <g transform="translate(1024 1024) rotate(-45)">
      <rect x="-300" y="-215" width="600" height="110" fill="${kz.red}"/>
      <rect x="-300" y="-206" width="600" height="92" fill="none" stroke="#ffffff" stroke-opacity="0.6" stroke-width="4" stroke-dasharray="14 10"/>
      <text x="0" y="-160" dominant-baseline="central" text-anchor="middle" font-family="Inter" font-weight="800" font-size="64" letter-spacing="7" fill="#ffffff">MOVED</text>
    </g>
  '';
in
runCommand "nixos-kz-logo"
{
  nativeBuildInputs = [ resvg ];
  src = "${nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
}
  ''
    mkdir -p $out && cd $out

    sed ${recolor dark kz.blueShades} ${recolor light kz.goldShades} \
      -e 's/sodipodi:docname="[^"]*"/sodipodi:docname="nixos-kz-snowflake.svg"/' \
      "$src" > nixos-kz-snowflake.svg

    ${avatar}
    avatar nixos-kz-snowflake.svg "" > nixos-kz-avatar.svg
    avatar nixos-kz-snowflake.svg '${movedRibbon}' > reserved.svg
    usvg --font-family Inter --use-font-file ${inter}/share/fonts/truetype/Inter.ttc \
      reserved.svg nixos-kz-reserved-avatar.svg
    rm reserved.svg

    ${render "nixos-kz-snowflake"}
    ${render "nixos-kz-avatar"}
    ${render "nixos-kz-reserved-avatar"}
  ''
