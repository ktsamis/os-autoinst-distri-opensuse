# SUSE's openQA tests
#
# Copyright © 2009-2013 Bernhard M. Wiedemann
# Copyright © 2012-2016 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Test java plugin integration in firefox (Case#1436069)
# Maintainer: wnereiz <wnereiz@gmail.com>

use strict;
use base "x11regressiontest";
use testapi;
use utils qw(leap_version_at_least sle_version_at_least);

sub java_testing {
    my ($self) = @_;

    send_key "ctrl-t";
    assert_screen 'firefox-new-tab';
    send_key "alt-d";
    type_string "http://www.java.com/en/download/installed.jsp?detect=jre\n";

    wait_still_screen 3;
    assert_and_click('firefox-java-agree-and-proceed') if check_screen('oracle-cookies-handling', 0);

    wait_still_screen 3;
    if (check_screen('firefox-java-security', 0)) {
        assert_and_click('firefox-java-securityrun');
        assert_and_click('firefox-java-run_confirm');
    }

    $self->firefox_check_popups;

    wait_still_screen 3;
    assert_screen([qw(firefox-java-verifyversion firefox-java-verifyfailed firefox-java-verifypassed firefox-newer-java-available)]);

    if (match_has_tag 'firefox-java-verifyversion') {
        assert_and_click "firefox-java-verifyversion";
    }
    # Newer version of java is available
    if (match_has_tag 'firefox-newer-java-available') {
        record_info('Newer java version available',
            "Aim of the test is to verify that java is installed and works in browser, it's acceptable that it's not always latest version.");
        return;
    }
    return if match_has_tag 'firefox-java-verifyfailed';
    return if match_has_tag 'firefox-java-verifypassed';
}


sub run {
    my ($self) = @_;

    # FF 56 no longer support NPAPI plugins, e.g. Java
    if (sle_version_at_least('15') || leap_version_at_least('15.0')) {
        record_info('NPAPI plugins not supported',
            "FF 56 no longer supports supports NPAPI plugins, e.g. Java, so the test would fail in current distribution releases.");
        return;
    }

    $self->start_firefox;

    #Required only on sle, as open mozilla home page
    if (check_var('DISTRI', 'sle')) {
        assert_and_click('firefox-logo');
    }
    send_key "ctrl-shift-a";

    assert_screen("firefox-java-addonsmanager");
    assert_and_click('firefox-java-extensions');

    send_key "/";
    type_string "iced\n";

    #Focus to "Available Add-ons"
    assert_and_click "firefox-java-myaddons";

    #Focus to "Ask to Activate"
    assert_and_click "firefox-java-asktoactivate";

    #Focus to "Never Activate"
    send_key "up";
    send_key "ret";

    assert_screen("firefox-java-neveractive");

    $self->java_testing;
    assert_screen("firefox-java-verifyfailed", 90);

    send_key "ctrl-w";

    #Focus to "Always Activate"
    for my $i (1 .. 2) { send_key "down"; }
    assert_screen("firefox-java-active", 60);

    $self->java_testing;
    # If java version is not latest in official repos
    assert_screen([qw(firefox-java-verifypassed firefox-newer-java-available)], 90);

    $self->exit_firefox;
}
1;
# vim: set sw=4 et:
