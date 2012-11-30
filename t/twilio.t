#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Log::Dispatch;
use Log::Dispatch::Twilio;

###############################################################################
### Ensure that we have all of the ENV vars we need for testing.
unless ($ENV{TWILIO_ACCOUNT_SID}) {
    plan skip_all => "TWILIO_ACCOUNT_SID must be set in your environment for testing.";
}
unless ($ENV{TWILIO_ACCOUNT_TOKEN}) {
    plan skip_all => "TWILIO_ACCOUNT_TOKEN must be set in your environment for testing.";
}
unless ($ENV{TWILIO_FROM}) {
    plan skip_all => "TWILIO_FROM must be set in your environment for testing.";
}
unless ($ENV{TWILIO_TO}) {
    plan skip_all => "TWILIO_TO must be set in your environment for testing.";
}
plan tests => 8;

###############################################################################
### TEST PARAMETERS
my %params = (
    account_sid => $ENV{TWILIO_ACCOUNT_SID},
    auth_token  => $ENV{TWILIO_ACCOUNT_TOKEN},
    from        => $ENV{TWILIO_FROM},
    to          => $ENV{TWILIO_TO},
);

###############################################################################
# Required parameters for instantiation.
required_parameters: {
    foreach my $p (sort keys %params) {
        my %data = %params;
        delete $data{$p};

        my $output = eval {
            Log::Dispatch::Twilio->new(
                name      => 'twilio',
                min_level => 'debug',
                %data,
            );
        };
        like $@, qr/requires '$p' parameter/, "$p is required parameter";
    }
}

###############################################################################
# Instantiation.
instantiation: {
    my $output = Log::Dispatch::Twilio->new(
        name      => 'twilio',
        min_level => 'debug',
        %params,
    );
    isa_ok $output, 'Log::Dispatch::Twilio';
}

###############################################################################
# Instantiation via Log::Dispatch;
instantiation_via_log_dispatch: {
    my $logger = Log::Dispatch->new(
        outputs => [
            ['Twilio',
                name      => 'twilio',
                min_level => 'debug',
                %params,
            ],
        ],
    );
    isa_ok $logger, 'Log::Dispatch';

    my $output = $logger->output('twilio');
    isa_ok $output, 'Log::Dispatch::Twilio';
}

###############################################################################
# Logging test
logging_test: {
    my $logger = Log::Dispatch->new(
        outputs => [
            ['Twilio',
                name      => 'twilio',
                min_level => 'debug',
                %params,
            ],
        ],
    );

    my @messages;
    local $SIG{__WARN__} = sub { push @messages, @_ };
    $logger->info("test message, logged via Twilio");

    ok !@messages, 'Message logged via Twilio';
}
