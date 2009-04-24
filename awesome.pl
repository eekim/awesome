#!/usr/bin/perl
#
# awesome.pl -- finger daemon for Identi.ca
#
# Late night hack inspired by @evan's dent (http://identi.ca/notice/3665697):
#
#     Q: who is awesome enough to make a finger protocol wrapper
#     for identi.ca? A: IT COULD BE YOU!
#
# Hacked by Eugene Eric Kim <eekim@blueoxen.com> on April 23, 2009.
# This code is hereby donated to the public domain.

use strict;
use IO::Socket;
use Net::Identica;
use Text::Wrap;

# replace these values with your username and password
my $USERNAME = 'foo';
my $PASSWORD = 'bar';

my $i = Net::Identica->new(username => $USERNAME, password => $PASSWORD);
my $s = IO::Socket::INET->new(LocalPort => 79,
                              Type => SOCK_STREAM,
                              Reuse => 1,
                              Listen => 10)
  or die "Error creating socket: $!\n";

while (my $c = $s->accept) {
    my $username = <$c>;
    $username =~ s/\r\n$//;

    # I'm using user_timeline() to get the latest status for two reasons.
    # First, Net::Twitter->show_status() seems to be broken, at least for
    # Identi.ca. Second, user_timeline() returns a hash with user data,
    # which gives me the user's name.
    my $tl = $i->user_timeline({ id => $username });

    printf $c "Login: %-33s", $username;
    print $c "Name: " . $tl->[0]->{user}->{name} . "\n";

    print $c "Plan:\n";
    print $c wrap('', '', $tl->[0]->{text}) . "\n";
}
close $s;
