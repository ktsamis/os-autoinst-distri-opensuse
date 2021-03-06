# SUSE's openQA tests
#
# Copyright (c) 2016 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Grep logs to find segfaults
# Maintainer: Loic Devulder <ldevulder@suse.com>

use base 'opensusebasetest';
use strict;
use testapi;
use lockapi;
use hacluster;

sub run {
    barrier_wait("FENCING_DONE_$cluster_name");
    ha_export_logs;
    assert_script_run '(( $(grep -sR segfault /var/log | wc -l) == 0 ))';
    barrier_wait("LOGS_CHECKED_$cluster_name");
}

1;
# vim: set sw=4 et:
