#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;

use File::Slurp;

#use AWE::Client;
#use AWE::Job;
#use SHOCK::Client;

#use JSON;
#use File::Basename;
use Data::Dumper;

#use AMETHSTAWE; only for direct

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
'workflow submission:',
[ 'matrix|m=s', "abundance matrix"],
[ 'groups|g=s',  "groups file" ],
[ 'commands|c=s',  "commands file" ],
[ 'tree|t=s',  "tree (optional)" ],
'',
'other commands:',
[ 'status|s=s' , 'show status of a given AWE job_id'],
[ 'results=s' , 'download results for a given AWE job_id'],
[ 'delete=s' , 'delete AWE Job (and SHOCK files) for a given AWE job_id'],
'',
'only local: (bypasses service)',
[ 'command_file|f=s', ""],
[ 'zip_prefix|z=s', ""],
'',
[ 'local', "", { hidden => 1  }], #deprecated
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


my $job_id = undef;
if ((defined $h->{'command_file'}) || (defined $h->{'zip_prefix'}) ) {
	#require AMETHSTAWE;
	#$job_id = AMETHSTAWE::amethst_main($h->{'matrix'}, $h->{'groups'},$h->{'commands'}, $h->{'tree'});
	
	$h->{'command_file'} || die "no command_file defined";
	$h->{'zip_prefix'} || die "no zip_prefix defined";
	
	my $KB_TOP = $ENV{'KB_TOP'};
	
	unless (defined $KB_TOP) {
		die "KB_TOP not defined";
	}
	
	if ($KB_TOP eq '') {
		die "KB_TOP not defined";
	}
	
	unless (-d $KB_TOP ) {
		die "KB_TOP directory \"$KB_TOP\" not found";
	}
	
	my $service_dir = $KB_TOP.'/services/amethst_service/';
	
	unless (-d $service_dir ) {
		die "AMETHST service directory \"$service_dir\" not found";
	}
	
	my $amethst_bin_dir = $service_dir.'AMETHST/';
	
	
	unless (-d $amethst_bin_dir ) {
		die "AMETHST bin directory \"$amethst_bin_dir\" not found";
	}
	
	my $amethst_pl = $amethst_bin_dir.'AMETHST.pl';
	
	
	unless (-e $amethst_pl) {
		die "\"$amethst_pl\" not found";
	}
	
	#print "found $amethst_pl\n";
	
	my $cmd = $amethst_pl.' -f '.$h->{'command_file'}.' -z '.$h->{'zip_prefix'};
	print "cmd: $cmd\n";
	system($cmd);
	
} elsif ((defined $h->{'matrix'}) || (defined $h->{'groups'}) || (defined $h->{'commands'})) {
	
	require Bio::KBase::AmethstService::AmethstServiceImpl;
	
	$h->{'matrix'} || die "no matrix file defined";
	$h->{'groups'} || die "no groups file defined";
	$h->{'commands'} || die "no commands file defined";
	
	# slurp all files
	my $abundance_matrix_data = read_file( $h->{'matrix'});
	my $groups_list_data = read_file( $h->{'groups'});
	my $commands_list_data = read_file( $h->{'commands'});
	my $tree_data = undef;
	if (defined $h->{'tree'}){
		$tree_data = read_file($h->{'tree'});
	}
	
	my $amethst_obj = new Bio::KBase::AmethstService::AmethstServiceImpl;
	
	
	$job_id = $amethst_obj->amethst($abundance_matrix_data, $groups_list_data, $commands_list_data, $tree_data);
	
	unless (defined $job_id) {
		$job_id = 'undefined';
	}
	print "job submitted, job_id: $job_id\n";
	
	
	
} elsif (defined $h->{'status'}) {
	
	require Bio::KBase::AmethstService::AmethstServiceImpl;
	
	my $amethst_obj = new Bio::KBase::AmethstService::AmethstServiceImpl;
	my $status = $amethst_obj->status($h->{'status'}) || 'undefined';

	print "status: ".$status."\n";
	
	
} elsif (defined $h->{'results'}) {
	
	require Bio::KBase::AmethstService::AmethstServiceImpl;
	
	my $amethst_obj = new Bio::KBase::AmethstService::AmethstServiceImpl;
	my $results = $amethst_obj->results($h->{'results'}) || 'undefined';
	
	print "results: ".Dumper($results)."\n";
	
	foreach my $node (keys(%$results)) {
		my $file = $results->{$node};
		if (-e $file) {
			print "error: file $file already exists\n";
			exit(1);
		}
	}
	
	require SHOCK::Client;
	
	my $shock = new SHOCK::Client($shockurl, $shocktoken); # shock production
	unless (defined $shock) {
		die;
	}
	
	foreach my $node (keys(%$results)) {
		my $file = $results->{$node};
		
		print "downloading \"$file\" ...\n";
		$shock->download_to_path2($node, './'.$file);
		
	}
	print "all files downloaded\n";
	
} elsif (defined $h->{'delete'}) {

	require Bio::KBase::AmethstService::AmethstServiceImpl;
	
	my $amethst_obj = new Bio::KBase::AmethstService::AmethstServiceImpl;

	my $delete_status = $amethst_obj->delete_job($h->{'delete'}) || 'undefined';
	
	print "delete_status: $delete_status\n"
	
}
#unless (defined($h->{'nowait'})) {
#	AWE::Job::wait_and_download_job_results ('awe' => $awe, 'shock' => $shock, 'jobs' => [$job_id], 'clientgroup' => $clientgroup);
#}




