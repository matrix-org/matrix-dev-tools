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

my $usage = "Usage: $0 SIZE_LIMIT ROOT_PATH...\n";

my $limit = shift or die $usage;
my $root = shift or die $usage;

my @too_long_files;

while ($root) {
    find( \&analyseFile, $root );

    $root = shift;
}

if(scalar(@too_long_files) > 0) {
    print STDERR "Error: " . scalar(@too_long_files) . " file(s) has more than " . $limit ." lines.\n";

    print $_ . "\n" foreach(sort(@too_long_files));

    exit 1;
} else {
    print STDERR "All clear!\n";
    exit 0;
}

# Subs

sub analyseFile {
    my $file = $_;

    open my $INPUT, '<', $file or do {
        warn qq|WARNING: Could not open $File::Find::name\n|;
        return;
    };

    my $count = 0;

    while ( <$INPUT> ) {
        $count++;
    }

    close $INPUT;

    if($count > $limit) {
        push(@too_long_files, $file);
    }
}
