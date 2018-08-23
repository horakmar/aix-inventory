#!/usr/bin/perl
############################################ 
#  Skript pro pripravu tabulky pro upgrade
#  Vypisuje verzi OS, IP rozhrani a stav HACMP
#
#  Autor: Martin Horak
#  Verze: 1.0
#  Datum: 17. 1. 2015
#
############################################
use strict;

## Environment ## ==========================
################# ==========================
if($ENV{PATH} !~ m{/usr/local/bin}){
    $ENV{PATH} = '/usr/local/bin:' . $ENV{PATH};
}

$ENV{PATH} = $ENV{PATH} . ':/opt/freeware/lib/zabbix';

## Variables ## ============================
############### ============================
our $test = 0;
our $verbose = 1;
our @arg = ();

## Functions ## ============================
############### ============================
sub DoCMD{
    my $command = shift;
    print $command, "\n" if($verbose > 1);
    if($test == 0){
        my $err = qx/$command 2>&1/;
        print "Chyba: $err\n" if($? != 0);
    }
}

## Usage ## --------------------------------
sub Usage {
    my $script_name = substr($0, rindex($0, '/')+1);
    print <<"EOF";

Pouziti:
    $script_name [-h] [-tvq]

Program pro pripravu tabulky pro upgrade OS.
Vypisuje verzi OS, IP rozhrani a stav HACMP.

Parametry:
    -h  ... help - tato napoveda
    -t  ... test - neprovadet prikazy, pouze vypsat
    -v  ... verbose - vypisovat vice informaci
    -q  ... quiet - vypisovat mene informaci

Chyby:

EOF
    exit 1;
}
## Usage end ## ----------------------------

## Main ## =================================
########## =================================

## Getparam ## -----------------------------
my $a;
GetP: while(defined($a = shift)){
    if(substr($a, 0, 1) eq '-'){
        my @aa = split(//, $a);
        shift @aa;
        foreach my $i (@aa){
            if($i eq 'h'){ &Usage(); next; };
            if($i eq 't'){ $test = 1; next; };
            if($i eq 'v'){ $verbose++; next; };
            if($i eq 'q'){ $verbose--; next; };
        }
    }else{
        push(@arg, $a);
    }
}

# push(@arg, '') while(scalar @arg < 2);
## Getparam end ## -------------------------

my $release = qx/zbx_system_inv release/;
chomp $release;

my @ips_filt = ();
my $ips = qx/zbx_system_info_if alias/;
chomp $ips;
my @ips = split(';', $ips);
foreach my $i (@ips) {
    next if($i =~ /^svcz/);
    next if($i =~ /^(p|t|g|d)[p-r][a-z]\d/);
    next if($i eq '[Neznama]');
    push(@ips_filt, $i);
} 

my $ha_stat = qx/zbx_hacmp_status/;
chomp $ha_stat;
my $hacmp_stat = 'None';
$hacmp_stat = 'Online' if($ha_stat eq '1');
$hacmp_stat = 'Offline' if($ha_stat eq '0');

print "$release;", join(' ',@ips_filt), ";$hacmp_stat\n";

exit 0;

__END__

