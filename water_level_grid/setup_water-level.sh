# !/bin/bash
set -e
# Extract zip waterlevel data
# Rearrange into 15min,30min,60min interval waterlevel folders by date
setup_cmd=$1
DIR=$(pwd)
ROOT_DIR=${2-$DIR}
echo "Set ROOT_DIR=$ROOT_DIR"
cd $ROOT_DIR/water_level_grid
TAR=$(which tar)
if [ "${IS_UNIX:-0}" = "0" ]; then
    # https://superuser.com/a/318810
    TAR=$(which gtar)
fi

setup_cleanup() {
    rm -rf 60_min/2018-05-*/
    rm -rf 30_min/2018-05-*/
    rm -rf 15_min/2018-05-*/
}

hack_26() {
    cp -R 2018-05-25 2018-05-26
}

setup_prepare() {
    zip_files_cnt=$(find . -name 'water_level_grid-2018-05-*.zip' | wc -l)
    if [ "$files" == "30" ]
    then
    echo "All zip files exists"
    else
        echo "zip files not found. ${zip_file_cnt}"
        $TAR xzf waterlevel.tar.gz
    fi

    set +e
    echo "Copy dir to 15_min"
    unzip -n -q 'water_level_grid-2018-05-*.zip' -d 15_min
    cd 15_min && ls -d water_level_grid-2018-05-*/ | cut -f1 -d'/' | cut -c 18-27 | xargs -I '{}' mv water_level_grid-{} {} && cd ..

    echo "Copy dir to 30_min"
    unzip -n -q 'water_level_grid-2018-05-*.zip' -d 30_min
    cd 30_min && ls -d water_level_grid-2018-05-*/ | cut -f1 -d'/' | cut -c 18-27 | xargs -I '{}' mv water_level_grid-{} {} && cd ..

    echo "Copy dir to 60_min"
    unzip -n -q 'water_level_grid-2018-05-*.zip' -d 60_min
    cd 60_min && ls -d water_level_grid-2018-05-*/ | cut -f1 -d'/' | cut -c 18-27 | xargs -I '{}' mv water_level_grid-{} {} && cd ..
    set -e

    echo "Processing 15_min"
    cd 15_min
    hack_26
    for dd in $(ls -d 2018-05-*/ | cut -f1 -d'/'); do
        cd "$dd"
        echo ">>> 15_min/${dd}"
        find . -type f -not -name "water_level_grid-${dd}_*.asc" -delete
        ls | cut -c 18-40 | xargs -I '{}' mv water_level_grid-{} {}
        cd ..
        $TAR -czf "$dd.tar.gz" $dd
        rm -rf $dd
    done
    cd ..
    # $TAR -czf 15_min.tar.gz --include='*.tar.gz' 15_min/*
    find 15_min -name '*.tar.gz' | $TAR -czf 15_min.tar.gz --files-from -
    find 15_min -name '*.tar.gz' -delete

    echo "Processing 30_min"
    cd 30_min
    hack_26
    for dd in $(ls -d 2018-05-*/ | cut -f1 -d'/'); do
        cd "$dd"
        echo ">>> 30_min/${dd}"
        find . -type f -not -name "water_level_grid-${dd}_*-00-00.asc" -not -name "water_level_grid-${dd}_*-30-00.asc" -delete
        ls | cut -c 18-40 | xargs -I '{}' mv water_level_grid-{} {}
        cd ..
        $TAR -czf "$dd.tar.gz" $dd
        rm -rf $dd
    done
    cd ..
    # $TAR -czf 30_min.tar.gz --include='*.tar.gz' 30_min/*
    find 30_min -name '*.tar.gz' | $TAR -czf 30_min.tar.gz --files-from -
    find 30_min -name '*.tar.gz' -delete

    echo "Processing 60_min"
    cd 60_min
    hack_26
    for dd in $(ls -d 2018-05-*/ | cut -f1 -d'/'); do
        cd "$dd"
        echo ">>> 60_min/${dd}"
        find . -type f -not -name "water_level_grid-${dd}_*-00-00.asc" -delete
        ls | cut -c 18-40 | xargs -I '{}' mv water_level_grid-{} {}
        cd ..
        $TAR -czf "$dd.tar.gz" $dd
        rm -rf $dd
    done
    cd ..
    # $TAR -czf 60_min.tar.gz --include='*.tar.gz' 60_min/*
    find 60_min -name '*.tar.gz' | $TAR -czf 60_min.tar.gz --files-from -
    find 60_min -name '*.tar.gz' -delete
    
    echo "Finish"
    find . -name 'water_level_grid-2018-05-*.zip' -delete
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
setup_help() {
  progName=`basename "$0"`
  echo "-h | --help: Usage
  $progName  <COMMAND>
    - COMMAND: help | extract | prepare | cleanup | populate
  e.g.
  $progName prepare
    Segregate single file data into multiple grid file dirs based on date. And Separate into main dirs of 15min, 30min, 60min and create tar files
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