use Serializable;
use BSON::Document;

class MyClass {...}

class MyClass::Serializer does Serializer
{
    multi method serialize(Mu:D $obj --> Blob)
    {
        my $d = BSON::Document.new;
        $d<name> = $obj.name;
        $d<value> = $obj.value;
        $d<version> = $obj.version.Str;
        $d.encode;
    }

    multi method deserialize(Blob $buf, Mu $type)
    {
        my $d = BSON::Document.new($buf);
        $type.new(name => $d<name>,
                  value => $d<value>,
                  version => Version.new($d<version>));
    }
}

class MyClass does Serializable[MyClass::Serializer]
{
    has Str $.name;
    has Int $.value;
    has Version $.version;
}

my $x = MyClass.new(name => 'foo', value => 27,
    version => Version.new('0.0.1'));

my $buf = $x.serialize;

say "Serialized size: ", $buf.bytes;

my $y = MyClass.deserialize($buf);

say $y;
