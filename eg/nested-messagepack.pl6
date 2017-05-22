use v6;

use Serializable;
use Serializer::MessagePack;

class Foo does Serializable[Serializer::MessagePack]
{
    has Str $.something;
    has Int $.another;
}

class MyClass does Serializable[Serializer::MessagePack]
{
    has Str $.name;
    has Int $.value;
    has Foo $.foo
}

my $x = MyClass.new(name => 'foo', value => 27,
      foo => Foo.new(something => 'a string', another => 197));

say $x;

my $buf = $x.serialize;

say "Serialized size: ", $buf.bytes;

my $y = MyClass.deserialize($buf);

say $y;
