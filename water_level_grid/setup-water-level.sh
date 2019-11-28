# !/bin/bash
set -e
# Extract zip waterlevel data
# Rearrange into 15min,30min,60min interval waterlevel folders by date

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
        tar xzf waterlevel.tar.gz
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
        tar -czf "$dd.tar.gz" $dd
        rm -rf $dd
    done
    cd ..
    tar -czf 15_min.tar.gz --include='*.tar.gz' 15_min/*
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
        tar -czf "$dd.tar.gz" $dd
        rm -rf $dd
    done
    cd ..
    tar -czf 30_min.tar.gz --include='*.tar.gz' 30_min/*
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
        tar -czf "$dd.tar.gz" $dd
        rm -rf $dd
    done
    cd ..
    tar -czf 60_min.tar.gz --include='*.tar.gz' 60_min/*
    find 60_min -name '*.tar.gz' -delete
    
    echo "Finish"
    find . -name 'water_level_grid-2018-05-*.zip' -delete
}

setup_extract_15() {
    echo "Extracting 15_min"
    tar -xzf 15_min.tar.gz
    cd 15_min
    find . -name '*.tar.gz' -exec tar -xzf {} \;
    find . -name '*.tar.gz' -delete
    cd ..
}
setup_extract_30() {
    echo "Extracting 30_min"
    tar -xzf 30_min.tar.gz
    cd 30_min
    find . -name '*.tar.gz' -exec tar -xzf {} \;
    find . -name '*.tar.gz' -delete
    cd ..
}
setup_extract_60() {
    echo "Extracting 60_min"
    tar -xzf 60_min.tar.gz
    cd 60_min
    find . -name '*.tar.gz' -exec tar -xzf {} \;
    find . -name '*.tar.gz' -delete
    cd ..
}
setup_extract() {
    setup_extract_15
    setup_extract_30
    setup_extract_60
}


setup_cmd=$1
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