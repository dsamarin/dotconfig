#
# Print hilighted messages & private messages to window named "hilight" for
# irssi 0.7.99 by Timo Sirainen
#
# Modded a tiny bit by znx to stop private messages entering the hilighted
# window (can be toggled) and to put up a timestamp.
#

use Irssi;
use POSIX;
use vars qw($VERSION %IRSSI); 

$VERSION = "0.01";
%IRSSI = (
    authors     => "Devin \'eboyjr\' Samarin",
    contact     => "eboyjr14\@gmail.com", 
    name        => "pingpong",
    description => "Sends pong in response to directed ping",
    license     => "MIT Expat",
    changed     => "Wed Jun 27 12:51:27 PST 2012"
);

sub sig_hilight {

	my ($item) = @_;

	# We are not a public channel, return
	if ($item->{type} ne "CHANNEL") {
		return;
	}

	# We do not highlighted text, return
	if ($item->{data_level} != 3) {
		return;
	}

	my $server = $item->{server};

	if ($server->{usermode_away}) {
		$server->send_message($item->{name}, "I'll read that message soon.", 0);
	}

}

Irssi::signal_add('window item hilight', 'sig_hilight');
