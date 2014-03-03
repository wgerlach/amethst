#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

use AWE::Client;
use AWE::Job;
use SHOCK::Client;

use JSON;
use File::Basename;

use AMETHSTAWE;

use USAGEPOD qw(parse_options);


my $aweserverurl =  $ENV{'AWE_SERVER_URL'};
my $shockurl =  $ENV{'SHOCK_SERVER_URL'};
my $clientgroup = $ENV{'AWE_CLIENT_GROUP'};

my $shocktoken=$ENV{'GLOBUSONLINE'} || $ENV{'KB_AUTH_TOKEN'};


##############################################

my ($h, $help_text) = &parse_options (
'name' => 'mg-amethst -- wrapper for amethst',
'version' => '1',
'synopsis' => 'mg-amethst --matrix=<inputmatrix> --groups=<groupsfile> --commands=<commandsfile>',
'examples' => 'ls',
'authors' => 'Wolfgang Gerlach',
'options' => [
[ 'matrix|m=s', "abundance matrix"],
[ 'groups|g=s',  "groups file" ],
[ 'commands|c=s',  "commands file" ],
[ 'tree|t=s',  "tree (optional)" ],
#[ 'output|o=s', "out" ],
#[ 'nowait|n',   "asynchronous call" ],
[ 'help|h', "", { hidden => 1  }]
]
);



if ($h->{'help'} || keys(%$h)==0) {
	print $help_text;
	exit(0);
}

print "Configuration:\n";
print "aweserverurl: ".($aweserverurl || 'undef') ."\n";
print "shockurl: ". ($shockurl || 'undef') ."\n";
print "clientgroup: ". ($clientgroup || 'undef') ."\n\n";

#$h->{'input'} || die "no input defined";
#$h->{'output'} || die "no output defined";

$h->{'matrix'} || die "no matrix file defined";
$h->{'groups'} || die "no groups file defined";
$h->{'commands'} || die "no commands file defined";


#abundance_matrix, $groups_list, $commands_list, $tree
my $job_id = AMETHSTAWE::amethst_main($h->{'matrix'}, $h->{'groups'},$h->{'commands'}, ,$h->{'tree'});




print "job submitted: $job_id\n";

#unless (defined($h->{'nowait'})) {
#	AWE::Job::wait_and_download_job_results ('awe' => $awe, 'shock' => $shock, 'jobs' => [$job_id], 'clientgroup' => $clientgroup);
#}




print "finished\n";