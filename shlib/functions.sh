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
