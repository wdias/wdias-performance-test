#!/bin/bash
set -e
# Extract zip waterlevel data
# Rearrange into 15min,30min,60min interval waterlevel folders by date
setup_cmd=$1
DIR=$(pwd)
ROOT_DIR=${2-$DIR}
echo "Set ROOT_DIR=$ROOT_DIR"
cd $ROOT_DIR/precipitation
TAR=$(which tar)
if [ "${IS_UNIX:-0}" == "0" ]; then
    # https://superuser.com/a/318810
    TAR=$(which gtar)
fi

setup_cleanup() {
    echo "Clean up"
    declare -a locations=("attidiya" "battaramulla" "ibattara" "kottawa" "waga")
    echo "Clean 123"

    for dd in "${locations[@]}"
    do
        echo "cleaning ${dd}"
        find "15_min/${dd}" -name "2019-07-*_${dd}.csv" -delete
        find "30_min/${dd}" -name "2019-07-*_${dd}.csv" -delete
        find "60_min/${dd}" -name "2019-07-*_${dd}.csv" -delete
    done
}

setup_prepare() {
    # for i in `seq 1 1 31`; do echo $i; done
    # cp ibattara.csv 2019-07-01_ibattara.csv
    # sed -i '' '/2019-07-01/!d' 2019-07-01_ibattara.csv

    declare -a locations=("attidiya" "battaramulla" "ibattara" "kottawa" "waga")

    echo "Processing 15_min"
    cd 15_min
    for dd in "${locations[@]}"
    do
        echo ">>> 15_min/${dd}"
        $TAR -czf "$dd.tar.gz" $dd
        # rm -rf $dd
    done
    cd ..
    # $TAR -czf 15_min.tar.gz --include='*.tar.gz' 15_min/*
    find 15_min -name '*.tar.gz' | $TAR -czf 15_min.tar.gz --files-from -
    find 15_min -name '*.tar.gz' -delete

    echo "Processing 30_min"
    cd 30_min
    for dd in "${locations[@]}"
    do
        echo ">>> 30_min/${dd}"
        $TAR -czf "$dd.tar.gz" $dd
        # rm -rf $dd
    done
    cd ..
    # $TAR -czf 30_min.tar.gz --include='*.tar.gz' 30_min/*
    find 30_min -name '*.tar.gz' | $TAR -czf 30_min.tar.gz --files-from -
    find 30_min -name '*.tar.gz' -delete

    echo "Processing 60_min"
    cd 60_min
    for dd in "${locations[@]}"
    do
        echo ">>> 60_min/${dd}"
        $TAR -czf "$dd.tar.gz" $dd
        # rm -rf $dd
    done
    cd ..
    # $TAR -czf 60_min.tar.gz --include='*.tar.gz' 60_min/*
    find 60_min -name '*.tar.gz' | $TAR -czf 60_min.tar.gz --files-from -
    find 60_min -name '*.tar.gz' -delete
}

setup_extract_15() {
    echo "Extracting 15_min"
    $TAR -xzf 15_min.tar.gz
    cd 15_min
    find . -name '*.tar.gz' -exec $TAR -xzf {} \;
    find . -name '*.tar.gz' -delete
    cd ..
}
setup_extract_30() {
    echo "Extracting 30_min"
    $TAR -xzf 30_min.tar.gz
    cd 30_min
    find . -name '*.tar.gz' -exec $TAR -xzf {} \;
    find . -name '*.tar.gz' -delete
    cd ..
}
setup_extract_60() {
    echo "Extracting 60_min"
    $TAR -xzf 60_min.tar.gz
    cd 60_min
    find . -name '*.tar.gz' -exec $TAR -xzf {} \;
    find . -name '*.tar.gz' -delete
    cd ..
}
setup_extract() {
    setup_extract_15
    setup_extract_30
    setup_extract_60
}


case $setup_cmd in
  "" | "-h" | "--help")
    setup_help
    ;;
  *)
    shift
    setup_${setup_cmd} $@
    if [ $? = 127 ]; then
      echo "'${setup_cmd}' command not found." >&2
      echo "List available commands with '$progName --help'" >&2
      exit 1
    fi
    ;;
esac
