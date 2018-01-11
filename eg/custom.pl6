# A toy custom serialization for demonstration purposes, not much
# better than MessagePack in reality

use Serializable;

sub pack-str(Str $str --> Blob)  # Assume less than 256 bytes ;-)
{
    my $buf = $str.encode;
    buf8.new($buf.bytes) ~ $buf;
}

sub unpack-str(Blob $buf)
{
    my $strsize = $buf[0];
    my $str = $buf.subbuf(1..$strsize).decode;
    return ($str, $buf.subbuf($strsize+1));
}

class MyClass {...}

# 1 byte [size of name]
# n bytes of [encoded name]
# 1 byte [value]
# 1 byte [size of version string]
# n bytes of [encoded version string]
class MyClass::Serializer does Serializer
{
    multi method serialize(Mu:D $obj --> Blob)
    {
        my $buf = Buf.new;
        $buf ~= pack-str($obj.name);
        $buf ~= buf8.new($obj.value);         # Assume value less than 256
        $buf ~= pack-str($obj.version.Str);
    }

    multi method deserialize(Blob $buf, Mu $type)
    {
        my ($name, $buf2) = unpack-str($buf);
        my $value = $buf2[0];
        my ($version-str, $buf3) = unpack-str($buf2.subbuf(1));
        MyClass.new(:$name, :$value, version => Version.new($version-str));
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
