#!/usr/bin/env bash

log()  { printf "%b\n" "$*"; }
fail() { log "\nERROR: $*\n" ; exit 1 ; }

abspath() { echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"; }

clone() { 
	git clone https://github.com/sneerteam/$1.git || fail "Failing cloning $1"
}

pull() {
	git fetch
	git rebase origin/master
}

update() {
	if [[ -e ${ROOT}/$1 ]]; then
		pushd ${ROOT}/$1 &> /dev/null
		pull $1
	else
		pushd ${ROOT} &> /dev/null
		clone $1
	fi
	popd &> /dev/null
}

if [[ "$1" == "" ]]; then
	if [[ -e ../snapi ]]; then
		ROOT=`pwd`/..
	else
		ROOT=`pwd`
	fi
else
	ROOT=$1
fi

log "Sneer projects root is ${ROOT}"

[[ -e ${ROOT} ]] || mkdir -p ${ROOT}

update "server"
update "networker"
update "snapi"
update "android.main"
update "android.chat"

cd ${ROOT}/networker
./gradlew clean  || exit -1
./gradlew eclipse uploadArchives || exit -1
cp build/libs/networker-*.jar ../android.main/libs  || exit -1

cd ${ROOT}/snapi
./gradlew  || exit -1
