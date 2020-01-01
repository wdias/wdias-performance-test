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

declare -a locations=("attidiya" "battaramulla" "ibattara" "kottawa" "waga")

setup_cleanup() {
    echo "Clean up"
    echo "Clean 123"

    for dd in "${locations[@]}"
    do
        echo "cleaning ${dd}"
        find "15_min/${dd}" -name "2019-07-*_${dd}.csv" -delete
        find "30_min/${dd}" -name "2019-07-*_${dd}.csv" -delete
        find "60_min/${dd}" -name "2019-07-*_${dd}.csv" -delete
    done
}

setup_populate() {
    for dd in "${locations[@]}"
    do
        cd $dd
        for i in `seq 1 1 31`
        do
            date="2019-07-$(printf "%02d" $i)"
            echo "Processing for $dd >> $date"
            echo cp $dd.csv "${date}_${dd}.csv"
            cp $dd.csv "${date}_${dd}.csv"
            sed -i '' "/${date}/!d" "${date}_${dd}.csv"
            lines=$(head -n 96 "${date}_${dd}.csv")
            echo "$lines" > "${date}_${dd}.csv"
            sed -i '' "/${1:-:00Z}/!d" 2019-07-01_attidiya.csv
        done
        cd ..
    done
    # sed -i '' '/2019-07-01/!d' 2019-07-01_ibattara.csv
}

setup_prepare() {
    echo "Processing 15_min"
    cd 15_min
    setup_populate
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
    exit 0

    echo "Processing 30_min"
    cd 30_min
    setup_populate
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
    setup_populate
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
    echo $TAR -xzf 15_min.tar.gz
    $TAR -xzf 15_min.tar.gz
    cd 15_min
    find . -name '*.tar.gz' -exec $TAR -xzf {} \;
    find . -name '*.tar.gz' -delete
    cd ..
}
setup_extract_30() {
    echo "Extracting 30_min"
    echo $TAR -xzf 30_min.tar.gz
    $TAR -xzf 30_min.tar.gz
    cd 30_min
    find . -name '*.tar.gz' -exec $TAR -xzf {} \;
    find . -name '*.tar.gz' -delete
    cd ..
}
setup_extract_60() {
    echo "Extracting 60_min"
    echo $TAR -xzf 60_min.tar.gz
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
test_help() {
  progName=`basename "$0"`
  echo "-h | --help: Usage
  $progName  <COMMAND>
    - COMMAND: help | extract | prepare | cleanup | populate
  e.g.
  $progName prepare
    Segregate single file data into multiple files based on date. And Separate into main dirs of 15min, 30min, 60min and create tar files
  $progName extract
    Extract the tar files into 15min, 30min and 60min
  $progName cleanup
    Clean up extracted dirs
  "
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
