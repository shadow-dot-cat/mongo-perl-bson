use 5.008001;
use strict;
use warnings;
use utf8;

use Test::More 0.96;

binmode( Test::More->builder->$_, ":utf8" )
  for qw/output failure_output todo_output/;

use lib 't/lib';
use TestUtils;

use BSON qw/encode decode/;
use BSON::Types ':all';
use Tie::IxHash;

my ($hash);

# test BSON::Doc constructor
is( scalar @{bson_doc()}, 0, "empty bson_doc() is empty doc" );
is( scalar @{BSON::Doc->new}, 0, "empty constructor is empty doc" );

# test overloading
# XXX TBD

my @kv = qw/A B/;

subtest "Top level document" => sub {

    # hashref -> hashref
    $hash = decode( encode( { @kv } ) );
    is( ref($hash), 'HASH', "hashref->hashref" );
    is_deeply( $hash, { @kv }, "value correct" );

    # BSON::Doc -> hashref
    $hash = decode( encode( bson_doc( @kv ) ) );
    is( ref($hash), 'HASH', "BSON::Doc->hashref" );
    is_deeply( $hash, { @kv }, "value correct" );

    # BSON::Raw -> hashref
    $hash = decode( encode( bson_raw( encode { @kv } ) ) );
    is( ref($hash), 'HASH', "BSON::Raw->hashref" );
    is_deeply( $hash, { @kv }, "value correct" );

    # MongoDB::BSON::Raw -> hashref
    my $raw = encode({@kv});
    $hash = decode( encode( bless \$raw, "MongoDB::BSON::Raw" ) );
    is( ref($hash), 'HASH', "MongoDB::BSON::Raw->hashref" );
    is_deeply( $hash, { @kv }, "value correct" );

    # Tie::IxHash tied hashref
    tie my %ixhash, 'Tie::IxHash', @kv;
    $hash = decode( encode( \%ixhash ) );
    is( ref($hash), 'HASH', "Tie::IxHash(tied)->hashref" );
    is_deeply( $hash, { @kv }, "value correct" );

    # Tie::IxHash object
    my $ixdoc = Tie::IxHash->new(@kv);
    $hash = decode( encode( $ixdoc ) );
    is( ref($hash), 'HASH', "Tie::IxHash(OO)->hashref" );
    is_deeply( $hash, { @kv }, "value correct" );

};

subtest "Subdocument" => sub {

    # hashref -> hashref
    $hash = decode( encode( { doc => { @kv } } ) );
    is( ref($hash->{doc}), 'HASH', "hashref->hashref" );
    is_deeply( $hash, { doc => { @kv } }, "value correct" );

    # BSON::Doc -> hashref
    $hash = decode( encode( { doc => bson_doc( @kv ) } ) );
    is( ref($hash->{doc}), 'HASH', "BSON::Doc->hashref" );
    is_deeply( $hash->{doc}, { @kv }, "value correct" );

    # BSON::Raw -> hashref
    $hash = decode( encode( { doc => bson_raw( encode( { @kv } ) ) } ) );
    is( ref($hash->{doc}), 'HASH', "BSON::Raw->hashref" );
    is_deeply( $hash->{doc}, { @kv }, "value correct" );

    # MongoDB::BSON::Raw -> hashref
    my $raw = encode({@kv});
    $hash = decode( encode( { doc => bless \$raw, "MongoDB::BSON::Raw" } ) );
    is( ref($hash->{doc}), 'HASH', "MongoDB::BSON::Raw->hashref" );
    is_deeply( $hash->{doc}, { @kv }, "value correct" );

    # Tie::IxHash tied hashref
    tie my %ixhash, 'Tie::IxHash', @kv;
    $hash = decode( encode( { doc => \%ixhash } ) );
    is( ref($hash->{doc}), 'HASH', "Tie::IxHash(tied)->hashref" );
    is_deeply( $hash->{doc}, { @kv }, "value correct" );

    # Tie::IxHash object
    my $ixdoc = Tie::IxHash->new(@kv);
    $hash = decode( encode( { doc => $ixdoc } ) );
    is( ref($hash->{doc}), 'HASH', "Tie::IxHash(OO)->hashref" );
    is_deeply( $hash->{doc}, { @kv }, "value correct" );

};

subtest "Ordered top level doc" => sub {
    # hashref -> hashref
    $hash = decode( encode( { @kv } ), ordered => 1 );
    is( ref($hash), 'HASH', "hashref->hashref(ordered)" );
    ok( tied(%$hash), "hashref is tied" );
    is_deeply( $hash, { @kv }, "value correct" );

    # BSON::Doc -> hashref
    $hash = decode( encode( bson_doc( @kv, C => 'D' ) ), ordered => 1 );
    tie my %ixhash, 'Tie::IxHash', @kv, C => 'D';
    is( ref($hash), 'HASH', "BSON::Doc->hashref" );
    ok( tied(%$hash), "hashref is tied" );
    is_deeply( $hash, \%ixhash, "value correct" );

};

subtest "Ordered subdoc" => sub {

    # hashref -> hashref
    $hash = decode( encode( { doc => { @kv } } ), ordered => 1 );
    is( ref($hash->{doc}), 'HASH', "hashref->hashref" );
    ok( tied(%{$hash->{doc}}), "hashref is tied" );
    is_deeply( $hash, { doc => { @kv } }, "value correct" );

    # BSON::Doc -> hashref
    $hash = decode( encode( { doc => bson_doc( @kv, C => 'D' ) } ), ordered => 1 );
    tie my %ixhash, 'Tie::IxHash', @kv, C => 'D';
    is( ref($hash->{doc}), 'HASH', "BSON::Doc->hashref" );
    ok( tied(%{$hash->{doc}}), "hashref is tied" );
    is_deeply( $hash->{doc}, \%ixhash, "value correct" );

};

# TODO:
# Hash::Ordered to hashref
# DBRef callback testing (unless done in a separate test file)

done_testing;

# COPYRIGHT
#
# vim: set ts=4 sts=4 sw=4 et tw=75:
