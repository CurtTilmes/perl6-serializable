use Serializable;
use Serializer::YAMLish;
use Serializer::JSON;
use Serializer::MessagePack;
use Serializer::BSON;
use Serializer::LibYAML;

constant serializer = Serializer::JSON;
#constant serializer = Serializer::YAMLish;
#constant serializer = Serializer::LibYAML;
#constant serializer = Serializer::MessagePack;
#constant serializer = Serializer::BSON;

class MyClass does Serializable[serializer]
{
    has $.name;
    has $.value;
    has Version $.version is serialized-by('Str')
                          is deserialized-by('new');;
}

my $x = MyClass.new(name => 'foo', value => 27,
    version => Version.new('0.0.1'));

my $buf = $x.serialize;

say "Serialized size: ", $buf.bytes;

my $y = MyClass.deserialize($buf);

say $y;
