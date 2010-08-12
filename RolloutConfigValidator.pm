#!/usr/bin/perl -w
# vim:tw=100 sw=2 expandtab ft=perl

package RolloutConfigValidator;

use strict;
use warnings;
use Error ':try';
use vars qw( @EXPORT_OK );
@EXPORT_OK = qw( validate_config );

*c = *::c;
*v = *::v;

sub new {
  my($class) = @_;
  my $self = bless {}, $class;
  return $self;
}

sub validate_config {
  my($self, $val, $hostname) = @_;
  foreach my $global_config_key (keys %$val) {
    next unless my @config = c("$hostname/$global_config_key");
    foreach my $frag (@config) {
      eval {
        $self->_validate_config_item($global_config_key, $val->{$global_config_key}, $hostname,
                                     $frag);
      };
      if ($@) {
        my $d = new Data::Dumper [$frag], [qw( frag )];
        $d->Indent(0);
        $d->Terse(1);
        my $text = "Validation Error in configuration for $hostname\n";
        $text .= "Error: $@\n";
        $text .= "Config: $global_config_key => ".  $d->Dump();
        throw ConfigValidationException $text;
      };
    }
  }
}

sub _validate_config_item {
  my($self, $key, $config, $hostname, $value) = @_;
  throw ConfigValidationException "Error in step configuration: No 'type' for $key"
    unless $config->{type};
  my @types = (ref $config->{type} eq 'ARRAY') ? @{$config->{type}} : $config->{type};
  my @helps = (ref $config->{help} eq 'ARRAY') ? @{$config->{help}} : $config->{help};

  my $ex;
  for (my $i = 0; $i < @types; $i++) {
    my $type = $types[$i];
    my $help = $helps[$i] || "";

    my %all_types = (
      'boolean' => sub { $_[0] =~ /^[01]$/ },
      'code' => sub { ref $_[0] eq 'CODE' },
      'domainname' => sub { $_[0] =~ /^[a-z][a-z0-9\-.]+$/i },
      'hash' => sub { ref $_[0] eq 'HASH' },
      'hash_list' => sub { ref $_[0] eq 'ARRAY' },
      'int' => sub { $_[0] =~ /^\d+$/ },
      'ip' => sub { $_[0] =~ /^((([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.){3}([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])|[0-9:a-f]+)$/ },
      'list' => sub { ref $_[0] eq 'ARRAY' },
      'options' => sub { ref $_[0] eq 'HASH' },
      'options_list' => sub { ref $_[0] eq 'ARRAY' },
      'path' => sub { $_[0] =~ /^[a-z0-9_.\-:\/]/i },
      'string' => sub { defined($_[0]) && !ref $_[0] },
      'undef' => sub { 1 },
    );

    throw ConfigValidationException "Error in step configuration, unknown type '$type'"
      unless $all_types{$type};

    if (!$all_types{$type}->($value)) {
      my $text = "Expected type [". join(", ", @types).  "], got '". ($value || ""). "'";
      $text .= "\nHelp: $help" if $help;
      $ex = new ConfigValidationException $text;
      next;
    }

    if ($type eq 'hash') {
      while (my($xkey, $xvalue) = each(%$value)) {
        $self->_validate_config_item("$key/$xkey", $config->{key}, $hostname, $xkey)
            if $config->{key};
        $self->_validate_config_item("$key/$xkey", $config->{value}, $hostname, $xvalue)
            if $config->{value};
      }
      return;
    } elsif ($type eq 'options') {
      throw ConfigValidationException "Error in step configuration, no options"
        unless $config->{options};
      while (my($xkey, $xvalue) = each(%$value)) {
        if (!$config->{options}{$xkey}) {
          next if defined $config->{fail_on_unknown} && !$config->{fail_on_unknown};
          throw ConfigValidationException "'$xkey' is an unknown option for $key";
        }
        $self->_validate_config_item("$key/$xkey", $config->{options}{$xkey}, $hostname, $xvalue);
      }
      return;
    } elsif ($type eq 'options_list') {
      throw ConfigValidationException "Error in step configuration, no options"
        unless $config->{options};
      for (my $i = 0; $i < @$value; $i++) {
        my($xkey, $xvalue) = ($value->[$i], $value->[$i + 1]);
        if (!$config->{options}{$xkey}) {
          next if defined $config->{fail_on_unknown} && !$config->{fail_on_unknown};
          throw ConfigValidationException "'$xkey' is an unknown option for $key";
        }
        $self->_validate_config_item("$key/$xkey", $config->{options}{$xkey}, $hostname, $xvalue);
      }
      return;
    } elsif ($type eq 'boolean') {
      # Always return true
      return;
    } elsif ($type eq 'undef') {
      # Always return true
      return;
    } elsif ($type eq 'list') {
      # TODO(dparrish): list validation
      $self->_validate_config_item("$key/$_", $config->{items}, $hostname, $_)
        foreach @$value;
      return;
    } elsif ($type eq 'path') {
      if ((!defined($config->{absolute} || $config->{absolute}) && $value !~ /^\//)) {
        $ex = new ConfigValidationException "Path '$value' is required to be asbolute";
        next;
      }
      return;
    } elsif ($type eq 'hash_list') {
      for (my $i = 0; $i < @{$value}; $i += 2) {
        my($xkey, $xvalue) = ($value->[$i], $value->[$i + 1]);
        $self->_validate_config_item("$key/$xkey", $config->{key}, $hostname, $xkey)
            if $config->{key};
        $self->_validate_config_item("$key/$xkey", $config->{value}, $hostname, $xvalue)
            if $config->{value};
      }
      return;
    } elsif ($type eq 'code') {
      # TODO(dparrish): code validation
      return;
    } elsif ($type eq 'int') {
      if ($config->{range}) {
        my $text = "'$value' is outside range ". $config->{range}[0]. " <= x <= ".
                   $config->{range}[1];
        $text .= "\nHelp: $help" if $help;
        $ex = new ConfigValidationException $text and next
          if $value < $config->{range}[0] || $value > $config->{range}[1];
      }
      return;
    } elsif ($type eq 'string') {
      # TODO(dparrish): string validation
      if ($config->{regex}) {
        my $text = "'$value' does not match regex /$config->{regex}/";
        $text .= "\nHelp: $help" if $help;
        $ex = new ConfigValidationException $text and next
          unless $value =~ /$config->{regex}/;
      }
      return;
    }
  }
  $ex->throw if $ex;
}

1;
