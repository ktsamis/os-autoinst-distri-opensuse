# SUSE's openQA tests
#
# Copyright © 2009-2013 Bernhard M. Wiedemann
# Copyright © 2012-2016 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Test/execute the toggling of a separate home partition
# Maintainer: Stephan Kulow <coolo@suse.de>

use strict;
use base "y2logsstep";
use testapi;
use installation_user_settings;
use utils 'is_storage_ng';

sub run {
    wait_screen_change { send_key(is_storage_ng() ? 'alt-g' : 'alt-d') };    # open proposal settings
    if (is_storage_ng) {
        # On Xen PV "CDROM" is of the same type as a disk block device so YaST
        # naturally sees it as a "disk". We have to uncheck the "CDROM".
        if (check_var('VIRSH_VMM_TYPE', 'linux')) {
            assert_screen 'select-hard-disk';
            send_key 'alt-d';
            send_key $cmd{next};
        }
        assert_screen 'partition-scheme';
        send_key $cmd{next};
        installation_user_settings::await_password_check if get_var('ENCRYPT');
    }
    if (!check_screen 'disabledhome', 0) {
        # detect whether new (Radio Buttons) YaST behaviour
        my $new_radio_buttons = check_screen('inst-partition-radio-buttons', 0);
        send_key $new_radio_buttons ? 'alt-r' : 'alt-p';
    }
    assert_screen 'disabledhome';
    send_key(is_storage_ng() ? 'alt-n' : 'alt-o');    # finish editing settings
}

1;
# vim: set sw=4 et:
