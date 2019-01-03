#!/usr/bin/perl

#
# Copyright 2018 New Vector Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

use warnings;
use strict;
use File::Find;

my $usage = "Usage: $0 CONFIG_FILE ROOT_PATH...\n";

my $config_file = shift or die $usage;
my $root = shift or die $usage;

# Read configuration file

open my $CONFIG, '<', $config_file or die "Config file not found";

my %config;
my %configToRule;
my %last_found_occurrence_file;
my %last_found_occurrence_file_at_line;

# Note: if empty, all files will be checked
my @fileExtensionsToCheck;

my $lastRule = "";

while (<$CONFIG>) {
    chomp;

    # Skip empty lines
    if (/^$/) {
        $lastRule = "";
        next;
    }

    # Get the rule
    if (/^### (.*)/) {
        $lastRule = $1;
    }

    # Get a file extension
    if (/^# Extension:(.*)$/) {
        push(@fileExtensionsToCheck, $1);
    }

    # Skip comment (including rule)
    next if (/^#/);

    my @array = split("===");

    if (scalar(@array) > 1) {
        $config{$array[0]} = -1 * $array[1];
    }
    else {
        $config{$array[0]} = 0;
    }

    $configToRule{$array[0]} = $lastRule;
}

close $CONFIG;

while ($root) {
    find(\&analyseFile, $root);

    $root = shift;
}

my $error = 0;

foreach (sort (keys(%config))) {
    if ($config{$_} > 0) {
        if ($config{$_} > 1) {
            print "❌ Error: '" . $_ . "' detected " . $config{$_} . " times, last in file '" . $last_found_occurrence_file{$_} . "', at line " . $last_found_occurrence_file_at_line{$_} . ".\n";
        }
        else {
            print "❌ Error: '" . $_ . "' detected " . $config{$_} . " time, in file '" . $last_found_occurrence_file{$_} . "', at line " . $last_found_occurrence_file_at_line{$_} . ".\n";
        }

        print "Rule: " . $configToRule{$_} . "\n" if (length($configToRule{$_}) > 0);

        $error++;
    }
}

if ($error > 0) {
    if ($error > 1) {
        print STDERR $error . " forbidden patterns detected\n";
    }
    else {
        print STDERR $error . " forbidden pattern detected\n";
    }
    exit 1;
}
else {
    print STDERR "All clear!\n";
    exit 0;
}

# Subs

sub analyseFile {
    my $file = $_;

    my $analyseFile = 0;
    foreach (@fileExtensionsToCheck) {
        if ($file =~ /$_/) {
            $analyseFile = 1;
        }
    }

    return unless $analyseFile || scalar(@fileExtensionsToCheck) == 0;

    open my $INPUT, '<', $file or do {
        warn qq|WARNING: Could not open $File::Find::name\n|;
        return;
    };

    my $lineNumber = 0;

    while (<$INPUT>) {
        my $line = $_;

        $lineNumber++;

        foreach (keys(%config)) {
            if ($line =~ /$_/) {
                $config{$_}++;
                $last_found_occurrence_file{$_} = $File::Find::name;
                $last_found_occurrence_file_at_line{$_} = $lineNumber;
            }
        }
    }

    close $INPUT;
}
