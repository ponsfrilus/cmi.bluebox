linux_distribution_name() {
    if [ -f "/etc/redhat-release" ]; then
        case "$(cat /etc/redhat-release)" in
            CentOS*) echo "CentOS"; return ;;
            *Enterprise*) echo "RedHat"; return ;;
        esac
    elif grep -q DISTRIB_ID "/etc/lsb-release"; then
        . "/etc/lsb-release"
        echo "$DISTRIB_ID"
        return
    fi
    echo "Unknown"
}

ensure_running_as_root() {
    case "$(id -u)" in
        0) : ;;
        *) echo >&2 "This script must be run as root."; exit 2;;
    esac
}

check_docker_version() {
    local minversion=$1
    [ -z "$minversion" ] && minversion=1.4.0
    perl -w -Mstrict -Mversion \
         -e 'my $dockerversionstring = `docker --version`;' \
         -e 'my ($dockerversion) = $dockerversionstring =~
                       m/Docker version (\S+?)(,|\s)/i;' \
         -e 'if (! $dockerversion) { exit 2 };' \
         -e 'my $minversion = "'"$minversion"'";' \
         -e 'if (version->parse($dockerversion) <
                 version->parse($minversion)) {
               die "Docker version is $dockerversion, $minversion or higher required\n";
             }'
}

ensure_docker_installed() {
    local minversion=$1
    check_docker_version "$minversion"  && return
    
    case "$(linux_distribution_name)" in
        Ubuntu)
            # https://docs.docker.com/installation/ubuntulinux/
            [ -e /usr/lib/apt/methods/https ] || {
                apt-get update
                apt-get install apt-transport-https
            }
            apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 \
                    --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
            echo "deb https://get.docker.com/ubuntu docker main" \
                 > /etc/apt/sources.list.d/docker.list
            apt-get update
            apt-get install lxc-docker
            ;;
        RedHat|CentOS)
            yum -y install docker-io
            ;;
    esac
    check_docker_version "$minversion"  || {
        echo >&2 "Unable to install Docker."
        echo >&2 "Please install Docker $minversion or higher, and run the script again."
        exit 2
    }
}

confirm_yesno() {
    local question="$1"
    if which dialog >/dev/null 2>&1; then
        dialog --yesno "$question" 12 60
    else
        echo "$question [Yn]"
        read answer
        case "$answer" in
            n*|N*) return 1;;
            *) return 0;;
        esac
    fi
}

has_puppet() {
    which puppet >/dev/null 2>&1
}

# Whether puppet agent is configured.
has_puppet_agent() {
    grep -q "\[agent\]" $(puppet config print config 2>/dev/null)
}
