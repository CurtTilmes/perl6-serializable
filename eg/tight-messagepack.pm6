use Serializable;
use Data::MessagePack;

class MyClass {...}

# MessagePack an array of values, without field names

class MyClass::Serializer does Serializer
{
    multi method serialize(Mu:D $obj --> Blob)
    {
        Data::MessagePack::pack([$obj.name,
                                 $obj.value,
                                 $obj.version.Str]);
    }

    multi method deserialize(Blob $buf, Mu $type)
    {
        my $a = Data::MessagePack::unpack($buf);
        MyClass.new(name => $a[0],
                    value => $a[1],
                    version => Version.new($a[2]));
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
