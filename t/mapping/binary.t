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

my ($bson, $expect, $hash);

my $bindata = "\1\2\3\4\5";

# test constructor
is( bson_bytes(), '', "empty bson_bytes() is ''" );
is( BSON::Bytes->new->data, '', "empty BSON::Bytes constructor is ''" );
is( bson_bytes($bindata, 2)->subtype, 2, "bson_bytes(\$data, \$subtype) works" );

# test overloading
is( bson_bytes($bindata), $bindata, "BSON::Bytes string overload" );

# BSON::Bytes -> BSON::Bytes
$bson = $expect = encode( { A => bson_bytes($bindata) } );
$hash = decode( $bson );
is( ref( $hash->{A} ), 'BSON::Bytes', "BSON::Bytes->BSON::Bytes" );
is( "$hash->{A}", $bindata, "value correct" );

# scalarref -> BSON::Bytes
$bson = encode( { A => \$bindata } );
$hash = decode( $bson );
is( ref( $hash->{A} ), 'BSON::Bytes', "scalarref->BSON::Bytes" );
is( "$hash->{A}", $bindata, "value correct" );
is( $bson, $expect, "BSON correct" );

# BSON::Binary (deprecated) -> BSON::Bytes
$hash = encode( { A => BSON::Binary->new($bindata) } );
$hash = decode( $bson  );
is( ref( $hash->{A} ), 'BSON::Bytes', "BSON::Binary->BSON::Bytes" );
is( "$hash->{A}", $bindata, "value correct" );
is( $bson, $expect, "BSON correct" );

# MongoDB::BSON::Binary (deprecated) -> BSON::Bytes
SKIP: {
    eval { require MongoDB::BSON::Binary };
    skip( "MongoDB::BSON::Binary not installed", 2 )
      unless $INC{'MongoDB/BSON/Binary.pm'};
    $bson = encode( { A => MongoDB::BSON::Binary->new( data => $bindata ) } );
    $hash = decode( $bson  );
    is( ref( $hash->{A} ), 'BSON::Bytes', "MongoDB::BSON::Binary->BSON::Bytes" );
    is( "$hash->{A}",      $bindata,      "value correct" );
    is( $bson, $expect, "BSON correct" );
}

done_testing;

# COPYRIGHT
#
# vim: set ts=4 sts=4 sw=4 et tw=75:
