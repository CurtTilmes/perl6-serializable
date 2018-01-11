Serializable
============

This is an *experimental* attempt to develop a common, generic
interface to using various serialization modules to serialize
Perl 6 classes.

* [JSON::Marshal](https://github.com/jonathanstowe/JSON-Marshal)
* [JSON::Unmarshal](https://github.com/tadzik/JSON-Unmarshal)
* [JSON::Class](https://github.com/jonathanstowe/JSON-Class)
* [JSON::Fast](https://github.com/timo/json_fast)
* [YAMLish](https://github.com/Leont/yamlish)
* [LibYAML](https://github.com/yaml/yaml-libyaml-perl6)
* [Data::MessagePack](https://github.com/pierre-vigier/Perl6-Data-MessagePack)
* [MessagePack::Class](https://github.com/jonathanstowe/MessagePack-Class)
* [BSON](https://github.com/MARTIMM/BSON)
* [MsgPack](https://github.com/azawawi/perl6-msgpack/)

The goal is to define a generic interface role that can be built on by
everything else.

The interface I am cribbing is mostly taken from
[JSON::Class](https://github.com/jonathanstowe/JSON-Class),
[MessagePack::Class](https://github.com/jonathanstowe/MessagePack-Class)
and friends.  (Thanks @jonathanstowe!)

It looks like this:

A `Serializer` has two methods:

```
role Serializer
{
    multi method serialize(Mu:D $obj --> Blob) {...}

    multi method deserialize(Blob, Mu) {...}
}
```

A `Serializable` is a parameterized role that takes a specific
`Serializer`.  It provides the same two methods which just call the
methods on the supplied `Serializer` class.


```
role Serializable[Serializer $serializer]
{
     method serialize(--> Blob) {...}
     {
         $serializer.serialize(self)
     }

     method deserialize(Blob $buf, Mu $type = self)
     {
         $serializer.deserialize($buf, $type)
    }
}
```

I put the logic from the other classes into a top level
`Serializer::Hash` that just turns a `Class` into a `Hash` and back,
then subclass that (subrole?) into other `Serializer`s:

* `Serializer::JSON`
* `Serializer::MessagePack`
* `Serializer::YAMLish`
* `Serializer::LibYAML`
* `Serializer::BSON`
* `Serializer::MsgPack`

You can pick any of those to serialize a given class (for example,
with `Serializer::MessagePack`).

```
class MyClass does Serializable[Serializer::MessagePack]
{
    has $.name;
    has $.value;
}
```

Now objects of that class can be passed to other classes that just
need the class to be able to serialize/deserialize itself (`does`
`Serializable`) but don't care how it happens.

As the other `*::Class` modules, you can add some traits to customize:

```
class MyClass does Serializable[Serializer::JSON]
{
    has $.name;
    has $.value;
    has Version $.version is serialized-by('Str')
                          is deserialized-by('new');;
}
```

You can also just ignore the canned serializers and build a custom one:

```
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
```

# Acknowledgements

This builds heavily on the work of Jonathan Stowe.
