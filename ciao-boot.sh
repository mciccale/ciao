#!/bin/sh
#
#  ciao-boot.sh
#
#  Boot the Ciao builder
#
#  Copyright (C) Ciao Developer team
#

# Physical directory where the script is located
_base=$(e=$0;while test -L "$e";do d=$(dirname "$e");e=$(readlink "$e");\
        cd "$d";done;cd "$(dirname "$e")";pwd -P)

msg() {
    echo "=> boot: $*" 1>&2
}

# Fetch and patch _base (for network installation)
fetch() {
    branch=master
    url=https://github.com/ciao-lang/ciao/archive/$branch.tar.gz
    msg "fetching '$branch' branch (source code)"
    _base=$HOME/.ciaoroot/$branch
    if [ -x "$_base" ]; then
	cat <<EOF
ERROR: Directory $_base already exists.

Please remove it to force a new installation.

EOF
	exit 1
    fi
    mkdir -p "$_base"
    curl -SfL "$url" | tar -xz --strip-components 1 -C "$_base" -f -
}

if [ "$0" == "sh" ]; then
    # Stand-alone call. E.g.,
    #   curl -sSf https://raw.githubusercontent.com/ciao-lang/ciao/master/ciao-boot.sh | sh -s -- local-install
    fetch
    cd "$_base" # (needed for installation)
fi

$_base/builder/sh_boot/builder_boot.sh "$@"
