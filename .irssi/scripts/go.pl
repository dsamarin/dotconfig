use strict;
use vars qw($VERSION %IRSSI);
use Irssi;
use Irssi::Irc;
use feature 'switch';

# Usage:
# /script load go.pl
# If you are in #irssi you can type /go #irssi or /go irssi or even /go ir ...
# also try /go ir<tab> and /go  <tab> (that's two spaces)

$VERSION = '2.00';

%IRSSI = (
	authors     => 'nohar, eboyjr',
	contact     => 'nohar on freenode, eboyjr on freenode',
	name        => 'Go to window',
	description => 'Implements /go command that activates a window given a number/name/partial name. It features a nice completion.',
	license     => 'GPLv2 or later',
	changed     => '08-02-11'
);



sub go_command
{
	my ($name,$server,$witem) = @_;

	$name =~ s/^\s+|\s+$//g;
	
	# Wow I almost ported the window_highest_activity function, But I didn't.
	# Thanks to NChief in #irssi on freenode.
	# Invoking /go with no arguments will in effect call /window goto active.
	if ($name eq "") {
		Irssi::command("window goto active");
		return;
	}
	
	# First check for windows accessed by number
	if ($name =~ /^\d+$/) {
		my $window = Irssi::window_find_refnum($name);
		if (defined $window) {
			go_set_active($window);
			return;
		}
	}

	# Next check for windows accessed directly by name
	my $window = Irssi::window_find_item($name);
	if (defined $window) {
		go_set_active($window);
		return;
	}

	my ($alt_1st, $alt_2nd);

	my $active_win = Irssi::active_win();
	
	foreach my $window (Irssi::windows) {
		next unless (defined $window && ($active_win->{refnum} != $window->{refnum}));

		my $window_name = $window->get_active_name();

		given ($window_name) {
		
			# Next check for really close matches
			when (/^\W*\Q${name}\E$/i) {
				go_set_active($window);
				return;
			}
			
			# Check for partial beginning matches that we can use later
			when (!$alt_1st && /^\W*\Q${name}\E/i) {
				$alt_1st = $window;
			}
			
			# Also check for partial matches anywhere that we can use later
			when (!$alt_2nd && /\Q${name}\E/i) {
				$alt_2nd = $window;
			}
		}
	}

	if ($alt_1st) {
		go_set_active($alt_1st);
		return;
	}

	if ($alt_2nd) {
		go_set_active($alt_2nd);
		return;
	}
	
	# If window was not found, let me know
	go_print("No other window available matching `$name`.");
}



sub go_command_complete {
	my ($complist, $window, $word, $linestart, $want_space) = @_;
	
	my $cmdchars = Irssi::settings_get_str("cmdchars");
	return unless ($linestart =~ /^[\Q${cmdchars}\E]go/i);

	@$complist = ();
	foreach my $window (Irssi::windows) {
		next unless (defined $window);
		
		my $name = $window->get_active_name();
		if ($word ne "") {
			if ($name =~ /\Q${word}\E/i) {
				push(@$complist, $name);
			}
		} else {
			push(@$complist, $name);
		}
	}
	Irssi::signal_stop();
}



sub go_set_active
{
	my ($window) = @_;
	
	if (Irssi::active_win()->{refnum} == $window->{refnum}) {
		my $window_name = $window->get_active_name();
		go_print("Window `$window_name` is already active.");
		return;
	}
	
	$window->set_active();
};



sub go_print {
	my ($message) = @_;
	Irssi::active_win()->print($message);
}



Irssi::command_bind("go", "go_command");
Irssi::signal_add_first('complete word', 'go_command_complete');
