#!/usr/bin/env perl
# -*- mode: perl; -*-
#
# Copyright © Bahman Movaqar
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
####################################################################################################

use strict;
use warnings;
use utf8;
use feature ':5.30';
use open qw/ :std :encoding(UTF-8) /;
use Cwd qw(abs_path getcwd);
use File::Basename qw(dirname);

# Source file cache: $file_cache{filepath} = [ lines... ]
my %file_cache;

####################################################################################################
# get_file_lines(path)
####################################################################################################
sub get_file_lines {
    my ($path) = @_;
    return [] unless defined $path && length $path;
    return $file_cache{$path} if exists $file_cache{$path};
    if (-f $path && open(my $fh, '<', $path)) {
        my @lines = <$fh>;
        close($fh);
        $file_cache{$path} = \@lines;
        return \@lines;
    }
    $file_cache{$path} = [];
    return [];
}

####################################################################################################
# classify_scope(origin_type, file_path, root_dir, bmakelib_dir)
####################################################################################################
sub classify_scope {
    my ($origin_type, $file_path, $root_dir, $bmakelib_dir) = @_;
    return 'builtin' if defined $origin_type && $origin_type eq 'builtin';
    return 'builtin' unless defined $file_path && length $file_path;

    my $abs_file = -e $file_path ? abs_path($file_path) : $file_path;
    if (index($abs_file, $bmakelib_dir) == 0) {
        return 'included';
    }
    if (index($abs_file, $root_dir) == 0 || $file_path !~ m#^/#) {
        return 'local';
    }
    return 'included';
}

####################################################################################################
# find_symbol_in_files(symbol, type, root_dir)
####################################################################################################
sub find_symbol_in_files {
    my ($symbol, $type, $root_dir) = @_;
    for my $path (keys %file_cache) {
        my $lines = $file_cache{$path};
        for my $i (0 .. $#$lines) {
            my $line = $lines->[$i];
            if ($type eq 'target' && $line =~ /^\s*\Q$symbol\E\s*(?::|::)/) {
                return ($path, $i + 1);
            } elsif ($type eq 'variable' && $line =~ /^\s*\Q$symbol\E\s*[:?+]?=/) {
                return ($path, $i + 1);
            }
        }
    }
    my $root_makefile = "${root_dir}Makefile";
    if (-f $root_makefile && !exists $file_cache{$root_makefile}) {
        my $lines = get_file_lines($root_makefile);
        for my $i (0 .. $#$lines) {
            my $line = $lines->[$i];
            if ($type eq 'target' && $line =~ /^\s*\Q$symbol\E\s*(?::|::)/) {
                return ($root_makefile, $i + 1);
            } elsif ($type eq 'variable' && $line =~ /^\s*\Q$symbol\E\s*[:?+]?=/) {
                return ($root_makefile, $i + 1);
            }
        }
    }
    return (undef, undef);
}

####################################################################################################
# find_definition_index(symbol, lines_ref, line_hint)
####################################################################################################
sub find_definition_index {
    my ($symbol, $lines_ref, $line_hint) = @_;
    return undef unless @$lines_ref > 0;

    my $def_idx = $line_hint - 1;
    $def_idx = $#$lines_ref if $def_idx >= @$lines_ref;

    for (my $i = $def_idx; $i >= 0; $i--) {
        if ($lines_ref->[$i] =~ /^\s*\Q$symbol\E\s*(?::|::|[:?+]?=)/) {
            return $i;
        }
    }

    for my $i (0 .. $#$lines_ref) {
        if ($lines_ref->[$i] =~ /^\s*\Q$symbol\E\s*(?::|::|[:?+]?=)/) {
            return $i;
        }
    }

    return undef;
}

####################################################################################################
# extract_inline_docstring(line)
####################################################################################################
sub extract_inline_docstring {
    my ($line) = @_;
    return undef unless defined $line;
    if ($line =~ /(?:^|\s)##\s*(.+)$/) {
        my $doc = $1;
        $doc =~ s/^\s+|\s+$//g;
        return $doc if length $doc;
    }
    return undef;
}

####################################################################################################
# extract_docblock_docstring(lines_ref, def_idx)
####################################################################################################
sub extract_docblock_docstring {
    my ($lines_ref, $def_idx) = @_;
    my $idx = $def_idx - 1;

    while ($idx >= 0 && (
        $lines_ref->[$idx] =~ /^\s*(?:#.*)?$/ ||
        $lines_ref->[$idx] =~ /^\s*\.PHONY\s*:/ ||
        $lines_ref->[$idx] =~ /^\s*(?:ifneq|ifeq|ifdef|ifndef|endif|else)/
    )) {
        if ($lines_ref->[$idx] =~ /^#</) {
            my @block;
            $idx--;
            while ($idx >= 0 && $lines_ref->[$idx] !~ /^#>/) {
                my $l = $lines_ref->[$idx];
                if ($l =~ s/^#(?: {3}|\t)?//) {
                    $l =~ s/^\s+|\s+$//g;
                    unshift @block, $l if length $l && $l !~ /^#+\s+/ && $l !~ /^`/;
                }
                $idx--;
            }
            return $block[0] if @block;
            last;
        }
        $idx--;
    }

    return undef;
}

####################################################################################################
# extract_docstring(symbol, file_path, line_num)
####################################################################################################
sub extract_docstring {
    my ($symbol, $file_path, $line_num) = @_;
    return undef unless defined $file_path && -f $file_path && defined $line_num && $line_num > 0;

    my $lines = get_file_lines($file_path);
    return undef unless @$lines > 0;

    my $def_idx = find_definition_index($symbol, $lines, $line_num);
    return undef unless defined $def_idx;

    my $inline_doc = extract_inline_docstring($lines->[$def_idx]);
    return $inline_doc if defined $inline_doc;

    return extract_docblock_docstring($lines, $def_idx);
}

####################################################################################################
# parse_variable_line(line, active_scopes_ref, show_vars, root_dir, bmakelib_dir, variables_by_scope_ref)
####################################################################################################
sub parse_variable_line {
    my ($line, $active_scopes_ref, $show_vars, $root_dir, $bmakelib_dir, $variables_by_scope_ref) = @_;

    if ($line =~ /^# makefile \(from '([^']+)', line (\d+)\)/) {
        my $var_file = $1;
        my $var_line = $2;
        get_file_lines($var_file);
        my $decl_line = <STDIN>;
        return unless defined $decl_line;

        if ($decl_line =~ /^([a-zA-Z0-9_.-]+)\s*[:?+]?=/) {
            my $var_name = $1;
            unless ($var_name =~ /^bmakelib\..*\.__/ || $var_name =~ /^_bmakelib\./ || $var_name =~ /^__/) {
                my $scope = classify_scope('makefile', $var_file, $root_dir, $bmakelib_dir);
                if ($active_scopes_ref->{$scope} && $show_vars) {
                    my $doc = extract_docstring($var_name, $var_file, $var_line);
                    if (defined $doc) {
                        $variables_by_scope_ref->{$scope}{$var_name} = $doc;
                    }
                }
            }
        }
    }
}

####################################################################################################
# process_target(target_state_ref, active_scopes_ref, show_targets, root_dir, bmakelib_dir, targets_by_scope_ref)
####################################################################################################
sub process_target {
    my ($target_state_ref, $active_scopes_ref, $show_targets, $root_dir, $bmakelib_dir, $targets_by_scope_ref) = @_;

    my $name       = $target_state_ref->{name};
    my $file       = $target_state_ref->{file};
    my $line       = $target_state_ref->{line};
    my $builtin    = $target_state_ref->{builtin};
    my $not_target = $target_state_ref->{not_target};

    # Always reset state for next target
    $target_state_ref->{name}       = undef;
    $target_state_ref->{file}       = undef;
    $target_state_ref->{line}       = undef;
    $target_state_ref->{builtin}    = 0;
    $target_state_ref->{not_target} = 0;

    return unless defined $name;
    return if $not_target;
    return if $name =~ /^[._%]/ || $name =~ /!/ || $name =~ /^_bmakelib\./ || $name eq 'Makefile';

    if (!$builtin && !defined $file) {
        ($file, $line) = find_symbol_in_files($name, 'target', $root_dir);
    }

    my $scope = $builtin ? 'builtin' : classify_scope('makefile', $file, $root_dir, $bmakelib_dir);
    if ($active_scopes_ref->{$scope} && $show_targets) {
        my $doc = extract_docstring($name, $file, $line);
        if (defined $doc) {
            $targets_by_scope_ref->{$scope}{$name} = $doc;
        }
    }
}

####################################################################################################
# parse_database(root_dir, bmakelib_dir, show_targets, show_vars, active_scopes_ref)
####################################################################################################
sub parse_database {
    my ($root_dir, $bmakelib_dir, $show_targets, $show_vars, $active_scopes_ref) = @_;

    my %targets_by_scope   = (local => {}, included => {}, builtin => {});
    my %variables_by_scope = (local => {}, included => {}, builtin => {});

    my $in_files = 0;
    my $seen_pattern_vars = 0;

    my %target_state = (
        name       => undef,
        file       => undef,
        line       => undef,
        builtin    => 0,
        not_target => 0,
    );

    while (my $line = <STDIN>) {
        if (!$in_files) {
            if ($line =~ /^# (?:Pattern-specific Variable Values|No pattern-specific variable values\.)/) {
                $seen_pattern_vars = 1;
                next;
            }
            if ($seen_pattern_vars && $line =~ /^# Files\s*$/) {
                $in_files = 1;
                next;
            }
            parse_variable_line(
                $line,
                $active_scopes_ref,
                $show_vars,
                $root_dir,
                $bmakelib_dir,
                \%variables_by_scope,
            );
        } else {
            if ($line =~ /^# Not a target:/) {
                $target_state{not_target} = 1;
            } elsif ($line =~ /^#\s+recipe to execute \(from '([^']+)', line (\d+)\):/) {
                $target_state{file} = $1;
                $target_state{line} = $2;
                get_file_lines($target_state{file});
            } elsif ($line =~ /^#\s+(?:Builtin rule|recipe to execute \(built-in\))/) {
                $target_state{builtin} = 1;
            } elsif ($line =~ /^([a-zA-Z0-9_.-]+)\s*:(?!=)/) {
                process_target(
                    \%target_state,
                    $active_scopes_ref,
                    $show_targets,
                    $root_dir,
                    $bmakelib_dir,
                    \%targets_by_scope,
                );
                $target_state{name} = $1;
            } elsif ($line =~ /^\s*$/) {
                process_target(
                    \%target_state,
                    $active_scopes_ref,
                    $show_targets,
                    $root_dir,
                    $bmakelib_dir,
                    \%targets_by_scope,
                );
            } elsif ($line =~ /^# (?:VPATH Utilities|files hash-table-stats)/) {
                process_target(
                    \%target_state,
                    $active_scopes_ref,
                    $show_targets,
                    $root_dir,
                    $bmakelib_dir,
                    \%targets_by_scope,
                );
                last;
            }
        }
    }

    process_target(
        \%target_state,
        $active_scopes_ref,
        $show_targets,
        $root_dir,
        $bmakelib_dir,
        \%targets_by_scope,
    );

    return (\%targets_by_scope, \%variables_by_scope);
}

####################################################################################################
# render_section(section_title, items_ref)
####################################################################################################
sub render_section {
    my ($section_title, $items_ref) = @_;
    return unless keys %$items_ref;

    say "\n  $section_title";
    my $max_len = 0;
    for my $name (keys %$items_ref) {
        $max_len = length($name) if length($name) > $max_len;
    }
    for my $name (sort keys %$items_ref) {
        printf("    %-${max_len}s  %s\n", $name, $items_ref->{$name});
    }
}

####################################################################################################
# render_notes_footer()
####################################################################################################
sub render_notes_footer {
    say "-" x 80;
    say "Notes:";
    say "- Run 'env' to view the environment variables passed to Make.";
    say "- Use 'bmakelib.conf.help.scope=local|included|builtin|all' to control the scope.";
    say "- Use 'bmakelib.conf.help.targets=no' to skip targets.";
    say "- Use 'bmakelib.conf.help.variables=no' to skip variables.";
    say "- Use 'bmakelib.conf.help.tips=no' to silence this tip.";
}

####################################################################################################
# render_help(targets_by_scope_ref, variables_by_scope_ref, active_scopes_ref, show_targets, show_vars, show_tips)
####################################################################################################
sub render_help {
    my ($targets_by_scope_ref, $variables_by_scope_ref, $active_scopes_ref, $show_targets, $show_vars, $show_tips) = @_;

    my @scope_order = qw(local included builtin);
    my $has_rendered_any = 0;

    for my $sc (@scope_order) {
        next unless $active_scopes_ref->{$sc};
        my %t = %{$targets_by_scope_ref->{$sc}};
        my %v = %{$variables_by_scope_ref->{$sc}};
        next unless (keys %t || keys %v);

        $has_rendered_any = 1;
        my $banner_title = uc($sc);
        say "=" x 80;
        say "  $banner_title";
        say "=" x 80;

        render_section("TARGETS", \%t)   if $show_targets;
        render_section("VARIABLES", \%v) if $show_vars;
        say "";
    }

    render_notes_footer() if $show_tips && $has_rendered_any;
}

####################################################################################################
# main()
####################################################################################################
sub main {
    if (@ARGV != 5) {
        die "Usage: help.pl <root-dir> <targets:yes|no> <variables:yes|no> <scope:all|local|included|builtin> <tips:yes|no>\n";
    }

    my ($root_dir_raw, $show_targets_flag, $show_vars_flag, $scope_arg, $show_tips_flag) = @ARGV;

    my $root_dir = -d $root_dir_raw ? abs_path($root_dir_raw) : abs_path(getcwd());
    $root_dir =~ s#/*$#/#;

    my $bmakelib_dir = abs_path(dirname(__FILE__));
    $bmakelib_dir =~ s#/*$#/#;

    my $show_targets = ($show_targets_flag ne 'no');
    my $show_vars    = ($show_vars_flag ne 'no');
    my $show_tips    = ($show_tips_flag ne 'no');

    my %active_scopes;
    if ($scope_arg eq 'all') {
        %active_scopes = (local => 1, included => 1, builtin => 1);
    } else {
        for my $s (split(/[\s,]+/, $scope_arg)) {
            $active_scopes{$s} = 1 if $s =~ /^(local|included|builtin)$/;
        }
    }

    my ($targets_by_scope, $variables_by_scope) = parse_database(
        $root_dir,
        $bmakelib_dir,
        $show_targets,
        $show_vars,
        \%active_scopes,
    );

    render_help(
        $targets_by_scope,
        $variables_by_scope,
        \%active_scopes,
        $show_targets,
        $show_vars,
        $show_tips,
    );
}

main();
