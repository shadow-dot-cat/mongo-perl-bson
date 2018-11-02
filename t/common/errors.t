use 5.008001;
use strict;
use warnings;
use utf8;

use Test::More 0.96;

binmode( Test::More->builder->$_, ":utf8" )
  for qw/output failure_output todo_output/;

use lib 't/lib';
use lib 't/pvtlib';
use CleanEnv;
use TestUtils;

use BSON qw/encode decode/;
use BSON::Types ':all';

{
    my $obj = bless {}, "Some::Random::Class";
    eval { encode( { a => $obj } ) };
    like( $@, qr/For key 'a', can't encode value of type 'Some::Random::Class'/, "encoding unknown type is fatal" );
}

{
    no warnings 'once';
    my $glob = *foo;
    eval { encode( \$glob ) };
    like( $@, qr/Can't encode non-container of type 'GLOB'/, "encoding non-container is fatal" );
}

{
    my $with_null= "Hello\0World";
    eval { encode( { $with_null => 123 } ) };
    like( $@, qr/Key 'Hello\\x00World' contains null character/, "encoding embedded null is fatal" );
}

{
    eval { encode( "Hello world" ) };
    like( $@, qr/Can't encode scalars/, "encoding scalar is fatal" );
}


{
    eval { encode( qr/abc/ ) };
    like( $@, qr/Can't encode non-container of type '.*'/, "encoding non-container is fatal" );
}

{
    my $str = "123";
    my $obj = bless \$str, "Some::Object";
    eval { encode( $obj ) };
    like( $@, qr/Can't encode non-container of type 'Some::Object'/, "encoding hash-type object is fatal" );
}

{
    my %hundred_hash;
    create_nest(\%hundred_hash,100);
    eval { encode( \%hundred_hash ) };
    my $err = $@ || "Unknown Error";
    if ( index($err, "circular reference detected at") != -1 ) {
        like( $err,
            qr/circular reference detected at/,
            "Perl has a hard limit of 100 levels of recursion with warnings"
        );
    } else {
        like( $err,
            qr/Exceeded max object depth of/,
            "Hit the specified max depth of documents in BSON_MAX_DEPTH"
        ) or diag($err);
    }
}


done_testing;

# COPYRIGHT
#
# vim: set ts=4 sts=4 sw=4 et tw=75:
