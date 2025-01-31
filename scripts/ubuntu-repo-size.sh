# 8 Mar 2021: Added debug and workdir option, start of work on adding Ubuntu Cloud Archive and Archive.Canonical.com (Partner)
ubuntu-repo-size() {
  ubuntu-repo-size_usage() {
    printf "\n\e[1m\e[2G${FUNCNAME%%_*}\e[0m\n\n"
    printf "\e[1m\e[2GUsage\e[0m: ${FUNCNAME%%_*} [options]\n\n"
    printf "\e[1m\e[2GOptions\e[0m:\n\n"
    printf "\e[3G -a, --arch \e[28GArchitecture to display, i.e. amd64,arm64,armhf,i386,ppc64el,s390x (Default: amd64)\n"
    printf "\e[3G -s, --series \e[28GRelease nicknames to get information for, (Default: current LTS)\n"
    printf "\e[3G -c, --components \e[28GList of repo components to query (Default: main,universe,multiverse,restricted)\n"
    printf "\e[3G -p, --pockets \e[28GList of repo pockets components to query (Default: \$series \$series-updates \$series-backports \$series-security \$series-proposed)\n"
    printf "\e[3G -i, --intel-repo-uri \e[28GURI of ubuntu archive for amd64/i386 (Default: http://archive.ubuntu.com/ubuntu/dists)\n"
    printf "\e[3G -P, --ports-repo-uri \e[28GURI of ubuntu archive for arm64,armhf,i386,ppc64el,s390 (Default: http://ports.ubuntu.com/ubuntu/dists)\n"
    printf "\e[3G -o, --cloud \e[28GInclude Ubuntu-Cloud Openstack Archive (Default: false)\n"
    printf "\e[3G -C, --canonical \e[28GInclude Canonical's Partner Archive (Default: false)\n"
    printf "\e[3G -S, --scale \e[28GNumber of decimal places allowed in repository size calculation (Default: 0)\n"
    printf "\e[3G -f, --footnote \e[28GDisplay Ubuntu Advantage footnotes (Default: false)\n"
    printf "\e[3G -I, --iec \e[28GUse IEC binary prefixes, i.e. multiples of 1024, when reporting repo sizes (Default: Use SI decimal prefixes, i.e. powers of 10)\n"
    printf "\e[3G -k, --keep \e[28GKeep repo indices after script completes (Default: false)\n"
    printf "\e[3G -D, --debug \e[28GVerbose mode (Default: false)\n"
    printf "\e[3G -w, --work-dir\e[28GWorking directory (Default: /tmp})\n"
    printf "\e[3G -h, --help\e[28GThis message\n\n"
  };export -f ubuntu-repo-size_usage
  export SMODE='si' SMODEK='10^3' SMODEM='10^6' SMODEG='10^9' MB='MB' GB='GB'
  export SC=0 KEEP=false FN=false MAIN_FN='' UNIVERSE_FN='';
  declare -ag ARCHES=(amd64)
  declare -ag SERIES=(focal)
  declare -ag COMPONENTS=(main universe multiverse restricted)
  declare -ag POCKETS=(release updates backports security proposed)
  export REPO_URI_UBUNTU="http://us.archive.ubuntu.com/ubuntu/dists"
  export REPO_URI_PORTS="http://us.ports.ubuntu.com/ubuntu-ports/dists"
  export REPO_URI_CLOUD="http://ubuntu-cloud.archive.canonical.com/ubuntu/dists"
  export REPO_URI_PARTNER="http://archive.canonical.com/ubuntu/dists"
  declare -ag SUITES_CLOUD=($(curl -sSlL ${REPO_URI_CLOUD}|awk -F'>|/' '/folder/{print $11}'))
  declare -ag SUITES_CLOUD_O7K=($((for ((i=0; i<${#SUITES_CLOUD[@]}; i++)); do printf '%s/%s\n' ${REPO_URI_CLOUD} ${SUITES_CLOUD[$i]} ;done|xargs -rn1 -P0 bash -c 'curl -sSlL ${0}|awk -vURI=${0##*/} -F'"'"'>|/'"'"' '"'"'/folder/{print URI"/"$11}'"'"'')|sort -uV))
  declare -ag SERIES_CLOUD=($(printf '%s\n' ${SUITES_CLOUD[@]%-*}|sort -uV))
  declare -ag POCKETS_CLOUD=($(printf '%s\n' ${SUITES_CLOUD[@]##*-}|sort -uV))
  declare -ag COMPONENTS_PARTNER=(main)
  declare -ag SUITES_PARTNER=($(curl -sSlL ${REPO_URI_PARTNER}|awk -F'>|/' '/folder/$11 ~ /-/{print $11}'|sort -uV))
  declare -ag SERIES_PARTNER=($(printf '%s\n' ${SUITES_PARTNER[@]%-*}|sort -uV))
  declare -ag POCKETS_PARTNER=($(printf '%s/partner\n' ${SUITES_PARTNER[@]##*-}|sort -uV))
  export WARGS='--retry-connrefused --waitretry=1 --timeout=25 --tries=5 --continue --no-dns-cache -qN'
  export CARGS='-sSlL --connect-timeout 5 --max-time 20 --retry 5 --retry-delay 1'
  export WORK_DIR='/tmp'
  export DEBUG=false
  declare -ag REPO_EXT=(xz gz)
  ARGS=$(getopt -o a:s:c:p:oCi:P:S:fIkdw:h --long arch:,series:,components:,pockets:,intel-repo-uri:,ports-repo-uri:,cloud,canonical,debug,scale:,iec,keep,footnote,work-dir:,help -n ${FUNCNAME} -- "$@")
  eval set -- "$ARGS"
  while true ; do
    case "$1" in
      -a|--arch) declare -ag ARCHES=("${2//[,|:| ]/ }");shift 2;;
      -s|--series) declare -ag SERIES=("${2//[,|:| ]/ }");shift 2;;
      -c|--components) declare -ag COMPONENTS=("${2//[,|:| ]/ }");shift 2;;
      -p|--pockets) declare -ag POCKETS=("${2//[,|:| ]/ }");shift 2;;
      -i|--intel-repo-uri) export REPO_URI_INTEL="${2}";shift 2;;
      -P|--ports-repo-uri) export REPO_URI_PORTS="${2}";shift 2;;
      -o|--cloud) export CLOUD=true;shift 1;;
      -C|--canonical) export PARTNER=true;shift 1;;
      -S|--scale) export SC="${2}";shift 2;;
      -f|--footnote) export FN=true MAIN_FN='\b\e[1m\u2020\e[0m' UNIVERSE_FN='\b\e[1m\u00A7\e[0m';shift 1;;
      -I|--iec) export SMODE='iec' SMODEK='2^10' SMODEM='2^20' SMODEG='2^30' MB="MiB" GB="GiB";shift 1;;
      -k|--keep) export KEEP=true;return;;
      -w|--work-dir) export WORK_DIR=${2};shift 2;;
      -d|--debug) export DEBUG=true;shift 1;;
      --) shift;break;;
    esac
  done
(tput clear;tput civis
NOW=$(date +%s)sec
[[ ${DEBUG} = true ]] && { set -x > /dev/null 2>&1; }
[[ ${DEBUG} = true ]] && { export WARGS="${WARGS//-q/-}"; }
[[ ${DEBUG} = true ]] && { export CARGS="${CARGS//-sS/-v}"; }
tput clear;tput civis
export SRC_CNT=0 PKG_CNT=0 SRC_SZE=0 PKG_SZE=0
export TOTAL_SRC_CNT=0 TOTAL_PKG_CNT=0 TOTAL_SRC_SZE=0 TOTAL_PKG_SZE=0
export GTOTAL_SRC_CNT=0 GTOTAL_PKG_CNT=0 GTOTAL_SRC_SZE=0 GTOTAL_PKG_SZE=0
printf '\e[1mUbuntu Repository Size\e[0m\n\n'
((for w in ${ARCHES[@]};do
  [[ ! ${w} = amd64 && ! ${w} = i386 ]] && export REPO_URI=${REPO_URI_PORTS} || export REPO_URI=${REPO_URI_UBUNTU}
  for x in ${SERIES[@]};do
  	[[ ${x} = trusty ]] && export FEXT="gz" || export FEXT="xz"
    for y in $(printf "${x}-%s\n" ${POCKETS[@]//release/${x}}|sed "s/${x}-${x}/${x}/g");do
      #[[ ${y} = $(curl 2>/dev/null ${CARGS} ${REPO_URI}|grep 2>/dev/null -oP "(^|\s|\")\K${y}(/)"|sed "s/\/$//g") ]] || { printf "Cannot find Suite ${y} @ ${REPO_URI}\n";continue; };
      for z in ${COMPONENTS[@]};do
        echo "${WORK_DIR}/Ubuntu-Repo_${y}_${z}_Sources-${w}.${FEXT} ${REPO_URI}/${y}/${z}/source/Sources.${FEXT}";
        echo "${WORK_DIR}/Ubuntu-Repo_${y}_${z}_Packages-${w}.${FEXT} ${REPO_URI}/${y}/${z}/binary-${w}/Packages.${FEXT}"
      done
    done
  done
done)|xargs -rn2 -P0 bash -c 'printf 1>&2 "\r\e[2G- Downloading $(echo $0|awk -F_ "{print \$4\" index for \"\$2\"/\"\$3}")\e[K";wget ${WARGS} -O $0 $1';printf "\r\e[K\r")
[[ ${#SERIES[@]} = 1 ]] && export SWORD="release" || export SWORD="releases"
[[ ${#ARCHES[@]} = 1 ]] && export AWORD="arch" || export AWORD="arches"
export ACNT=${#ARCHES[@]} SCNT=${#SERIES[@]}
export REPO_FILE_SZE=$(du -acb $(find ${WORK_DIR:-/tmp} -maxdepth 1 -type f -regextype "posix-extended" -iregex '.*Ubuntu-Repo.*(Sources|Packages).*([x|g]z)')|awk '/total/{printf "%.'${SC}'f",$1/'${SMODEM}'}')
export REPO_FILE_CNT=$(find ${WORK_DIR:-/tmp} -maxdepth 1 -type f -regextype "posix-extended" -iregex '.*Ubuntu-Repo.*(Sources|Packages).*([x|g]z)'|wc -l)
printf 1>&2 "\r\e[2G- Fetched ${REPO_FILE_CNT//,} Package/Source indices totaling ${REPO_FILE_SZE//,} ${MB} in $(TZ=UTC date --date now-${NOW} '+%Hh:%Mm:%Ss')\e[K"
sleep 2
printf 1>&2 "\r\e[K\r"
(declare -ag HEADERS=('Series (Arch)' 'Suite' 'Component' 'Src Count' 'Src Size('$MB'/'$GB')' 'Pkg Count' 'Pkg Size('$MB'/'$GB')')
(printf "%s\n" "${HEADERS[@]}"|paste -sd'|'
for h in ${!HEADERS[@]};do eval printf "%.3s" "─"{1..${#HEADERS[$h]}};printf '\n';done|paste -sd'|')
for w in ${ARCHES[@]};do
  for x in ${SERIES[@]};do
  	[[ ${x} = trusty ]] && export FEXT="gz" || export FEXT="xz"
    for y in $(printf "${x}-%s\n" ${POCKETS[@]//release/${x}}|sed "s/${x}-${x}/${x}/g");do
      [[ ${y} = ${x} ]] && { printf "\e[0;1;38;2;255;255;255m\e[1;48;2;233;84;32m${x^} (${w})\e[0m|||||\n"; }
      #[[ ${y} = $(curl 2>/dev/null ${CARGS} ${REPO_URI}|grep 2>/dev/null -oP "(^|\s|\")\K${y}(/)"|sed "s/\/$//g") ]] || { printf "Cannot find suite ${y} @ ${REPO_URI}\n";continue; };
      for z in ${COMPONENTS[@]};do
      	[[ ${FEXT} = gz ]] && export RCAT=zcat
      	[[ ${FEXT} = xz ]] && export RCAT=xzcat
        printf 1>&2 "\r\e[2G- Processing ${WORK_DIR}/Ubuntu-Repo_${y}_${z}_Sources-${w}.${FEXT}\e[K\r"
        export S="$(${RCAT} ${WORK_DIR}/Ubuntu-Repo_${y}_${z}_Sources-${w}.${FEXT}|awk '/^Files:/,/^Checksums-Sha1/{if(/^Files:/) SCNT++;SSZE+=$2}END  { printf "%'"'"'d|%'"'"'.'${SC}'f/%.'$SC'f\n",SCNT,(SSZE/'${SMODEM}'),(SSZE/'${SMODEG}')}')"
        export SRC_CNT=${S%%|*}
        export SRC_SZE=${S##*|}
        export SRC_SZE_MB=${SRC_SZE%%/*}
        export SRC_SZE_GB=${SRC_SZE##*/}
        export TOTAL_SRC_CNT=$(echo "scale=${SC};${TOTAL_SRC_CNT//,}+${SRC_CNT//,}"|bc)
        export TOTAL_SRC_SZE=$(echo "scale=${SC};${TOTAL_SRC_SZE//,}+${SRC_SZE_MB//,}"|bc)
         printf 1>&2 "\r\e[2G- Processing ${WORK_DIR}/Ubuntu-Repo_${y}_${z}_Packages-${w}.${FEXT}\e[K\r"
        export P="$(${RCAT} ${WORK_DIR}/Ubuntu-Repo_${y}_${z}_Packages-${w}.${FEXT}|awk -vSM="${SMODE}" '/^Size: /{PSZE+=$2;PCNT++}END { printf "%'"'"'d|%'"'"'.'$SC'f/%.'$SC'f\n",PCNT,(PSZE/'${SMODEM}'),(PSZE/'${SMODEG}')}')"
        export PKG_CNT=${P%%|*}
        export PKG_SZE=${P##*|}        
        export PKG_SZE_MB=${PKG_SZE%%/*}
        export PKG_SZE_GB=${PKG_SZE##*/}
        export TOTAL_PKG_CNT=$(echo "scale=${SC};${TOTAL_PKG_CNT//,}+${PKG_CNT//,}"|bc)
        export TOTAL_PKG_SZE=$(echo "scale=${SC};${TOTAL_PKG_SZE//,}+${PKG_SZE_MB//,}"|bc)
        [[ ${y} = ${x} ]] && { printf "|${y} \e[3m(release)\e[0m|"; } || { printf "|${y}|"; }
        printf "${z}|${SRC_CNT}|${SRC_SZE_MB}/${SRC_SZE_GB}|${PKG_CNT}|${PKG_SZE_MB}/${PKG_SZE_GB}\e[0m\n"
      done
    done
    HEADERS[0]= HEADERS[1]= HEADERS[2]= 
    for h in ${!HEADERS[@]};do [[ ${#HEADERS[$h]} -ne 0 ]] && { eval printf "%.3s" "─"{1..${#HEADERS[$h]}};printf '\n';};done|paste -sd'|'|sed 's/^/|||/'
    printf "|${x^} (${w}) Totals:||${TOTAL_SRC_CNT}|${TOTAL_SRC_SZE}/$(echo "scale=${SC};${TOTAL_SRC_SZE//,}/${SMODEK}"|bc)|${TOTAL_PKG_CNT}|${TOTAL_PKG_SZE}/$(echo "scale=${SC};${TOTAL_PKG_SZE//,}/${SMODEK}"|bc)\n"
    export GTOTAL_SRC_CNT=$(echo "scale=${SC};${GTOTAL_SRC_CNT//,}+${TOTAL_SRC_CNT//,}"|bc);        
    export GTOTAL_SRC_SZE=$(echo "scale=${SC};${GTOTAL_SRC_SZE//,}+${TOTAL_SRC_SZE//,}"|bc);        
    export GTOTAL_PKG_CNT=$(echo "scale=${SC};${GTOTAL_PKG_CNT//,}+${TOTAL_PKG_CNT//,}"|bc);
    export GTOTAL_PKG_SZE=$(echo "scale=${SC};${GTOTAL_PKG_SZE//,}+${TOTAL_PKG_SZE//,}"|bc);
    export TOTAL_SRC_CNT=0 TOTAL_PKG_CNT=0 TOTAL_SRC_SZE=0 TOTAL_PKG_SZE=0
  done
done
HEADERS[0]= HEADERS[1]= HEADERS[2]= 
for h in ${!HEADERS[@]};do [[ ${#HEADERS[$h]} -ne 0 ]] && { eval printf "%.3s" "═"{1..${#HEADERS[$h]}};printf '\n';};done|paste -sd'|'|sed 's/^/|||/'
printf "\e[0;1;38;2;255;255;255m\e[1;48;2;233;84;32mGrand Totals:|||${GTOTAL_SRC_CNT}|${GTOTAL_SRC_SZE} ${MB}/$(echo "scale=${SC};${GTOTAL_SRC_SZE//,}/${SMODEK}"|bc) ${GB}|${GTOTAL_PKG_CNT}|${GTOTAL_PKG_SZE} ${MB}/$(echo "scale=${SC};${GTOTAL_PKG_SZE//,}/${SMODEK}"|bc) ${GB}\e[0m\n"
)|column -ts"|"|sed -r 's/^.*release.*.main\s\s|^.*updates.*.main\s\s|^.*security.*.main\s\s/'$(printf "&${MAIN_FN}")'/g;s/^.*release.*.universe\s\s|^.*updates.*.universe\s\s|^.*security.*.universe\s\s/'$(printf "&${UNIVERSE_FN}")'/g'
echo
tput cnorm
[[ ${FN} = true ]] && { printf "\n\e[$(($(printf '%s\n' ${SERIES[@]}|wc -L)+3))G\e[1m\u2020\u00A0\e[0mEligble for Extended Security Maintenance (ESM) with Ubuntu Advantage for Infrastructure\n"; }
[[ ${FN} = true ]] && { printf "\e[$(($(printf '%s\n' ${SERIES[@]}|wc -L)+3))G\e[1m\u00A7\u00A0\e[0mEligble for Extended Security Maintenance (ESM) with Ubuntu Advantage for Applications\n\n"; }
)
[[ ${KEEP} = false ]] && { find ${WORK_DIR} -maxdepth 1 -type f -regextype "posix-extended" -iregex '.*Ubuntu-Repo.*(Sources|Packages).*([x|g]z)' -delete; }
[[ ${DEBUG} = true ]] && { set +x > /dev/null 2>&1;  }
};export -f ubuntu-repo-size