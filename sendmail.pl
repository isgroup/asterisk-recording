#!/usr/bin/perl

use MIME::Lite;
use Net::SMTP;

if ($#ARGV < 3) {
	print "usage: sendmail.pl from_address to_address mail_host subject [file_type file_path file_name, ..]\n";
	exit;
}

my $from_address = $ARGV[0];
my $to_address = $ARGV[1];
my $mail_host = $ARGV[2];
my $subject = $ARGV[3];

my $message_body = '';
foreach $line (<STDIN>) {
	chomp($line);
	$message_body .= $line;
}

$msg = MIME::Lite->new (
	From => $from_address,
	To => $to_address,
	Cc => 'XXX@CHANGEME.TLD',
	Subject => $subject,
	Type =>'multipart/mixed'
) or die "Error creating multipart container: $!\n";

$msg->attach (
	Type => 'TEXT',
	Data => $message_body
) or die "Error adding the text message part: $!\n";

my $argc = 0;
foreach my $arg (@ARGV) {
	if ($argc > 3 && ($argc-4)%3 == 0) {
		$msg->attach (
			Type => $ARGV[$argc],
			Path => $ARGV[$argc+1],
			Filename => $ARGV[$argc+2],
			Disposition => 'attachment'
		) or die "Error adding ".$ARGV[$argc+1].": $!\n";
	}
	$argc++;
}

# MIME::Lite->send('smtp', $mail_host, Timeout=>60);
$msg->send;

