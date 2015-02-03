#!/bin/bash

set -e -x

: ${CHECKOUT_DIR:="$(dirname "$0")"}
case "$CHECKOUT_DIR" in
    .|./*)
        CHECKOUT_DIR="$PWD/$CHECKOUT_DIR";;
esac

. "$CHECKOUT_DIR"/shlib/functions.sh

has_puppet || {
    echo >&2 Please install puppet first.
    exit 1
}

: ${PUPPET_MODULES_DIR:="$(puppet agent --configprint modulepath | cut -d: -f1)"}

ln -sf "${CHECKOUT_DIR}"/noc/puppet/modules/blueboxnoc "$PUPPET_MODULES_DIR"/

ask_configure_site_pp() {
    local puppet_site_file="$(puppet apply --configprint manifest)"
    case "$puppet_site_file" in
        "")
            echo >&2 "Unable to determine path to site.pp file"
            exit 1;;
        /home/*)
            echo >&2 "This script must be run as root."
            exit 1;;
    esac
    if [ ! -f "$puppet_site_file" ]; then
        if has_puppet_agent; then
            echo >&2 "This is *not* the puppet master; cannot install NOC here."
            return
        fi        
    fi
    grep -q blueboxnoc "$puppet_site_file" && return 0
    confirm_yesno "Set up $puppet_site_file automatically?" || return 0

    # I wish we could use Augeas here (and configure Puppet with itself, yow!)
    # but Perl just gets the job done easier.
    perl <(cat <<'EOF'
my $puppet_site_file = $ARGV[0];
my $hostname = $ARGV[1];

use FileHandle;
my $fh = FileHandle->new($puppet_site_file, "r");

if (! $fh) {
  $fh = FileHandle->new("/dev/null", "w");
}

our $in_node_section;
our $nesting = 0;

my $include_line_emitted;
sub emit_include_line {
  return if ($include_line_emitted);
  print (("  " x $nesting) . "include blueboxnoc\n");
  $include_line_emitted = 1;
}

while(<$fh>) {
  if (m|node .*$hostname|) {
    $in_node_section = 1;
  }
  if (m/{/) {
    $nesting += 1;
  }
  if (m/include.*blueboxnoc/ && $in_node_section) {
    next;
  }
  if (m/}/) {
    if ($in_node_section && ($nesting == 1)) {
      emit_include_line();
    }
    $nesting -= 1;
  }
  print;
}
warn "Done";

EOF
) "$puppet_site_file" "$(facter fqdn)" > "$puppet_site_file".new
    mv "$puppet_site_file".new "$puppet_site_file"
         
}

ask_configure_site_pp

if has_puppet_agent; then
    echo >&2 "Puppet has an agent configured; next agent run should apply the configuration."
    exit 0
else
    # Don't install the whole shebang, just "puppet apply" in a crontab
    # Recipe from https://docs.puppetlabs.com/guides/install_puppet/post_install.html
    puppet resource cron puppet-apply ensure=present user=root minute=30 command="/usr/bin/puppet apply '$(puppet apply --configprint manifest)'"
fi
