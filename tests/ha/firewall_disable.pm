# SUSE's openQA tests
#
# Copyright (c) 2016 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Disable firewall in HA tests
# Maintainer: Loic Devulder <ldevulder@suse.com>

use base 'opensusebasetest';
use strict;
use utils 'sle_version_at_least';
use testapi;
use hacluster;

sub run {
    my $firewall = 'SuSEfirewall2';

    # SLE/openSUSE-15 use firewalld instead of the old SuSEfirewall2
    if (sle_version_at_least('15')) {
        $firewall = 'firewalld';
    }

    # Deactivate firewall if needed
    if (script_run("rpm -q $firewall >/dev/null") == 0) {
        assert_script_run "systemctl -q is-active $firewall && systemctl disable $firewall; systemctl stop $firewall";
    }
}

1;
# vim: set sw=4 et:
