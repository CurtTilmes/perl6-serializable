use v6;

role CustomMarshaller
{
    method marshal($value, Mu:D $object) { ... }
}

role CustomMarshallerCode does CustomMarshaller
{
    has &.marshaller is rw;

    method marshal($value, Mu:D $object)
    {
        self.marshaller.($value);
    }
}

role CustomMarshallerMethod does CustomMarshaller
{
    has Str $.marshaller is rw;

    method marshal($value, Mu:D $type)
    {
        my $meth = self.marshaller;
        $value.defined ?? $value."$meth"() !! $type;
    }
}

multi sub trait_mod:<is> (Attribute $attr, :&serialized-by!) is export
{
    $attr does CustomMarshallerCode;
    $attr.marshaller = &serialized-by;
}

multi sub trait_mod:<is> (Attribute $attr, Str:D :$serialized-by!) is export
{
    $attr does CustomMarshallerMethod;
    $attr.marshaller = $serialized-by;
}

#----------------------------------------------------------------------

role CustomUnmarshaller
{
    method unmarshal($value, Mu:U $type) { ... }
}

role CustomUnmarshallerCode does CustomUnmarshaller
{
    has &.unmarshaller is rw;

    method unmarshal($value, Mu:U $type)
    {
        self.unmarshaller.($value);
    }
}

role CustomUnmarshallerMethod does CustomUnmarshaller
{
    has Str $.unmarshaller is rw;

    method unmarshal($value, Mu:U $type)
    {
        $type."$!unmarshaller"($value);
    }
}

multi sub trait_mod:<is> (Attribute $attr, :&deserialized-by!) is export
{
    $attr does CustomUnmarshallerCode;
    $attr.unmarshaller = &deserialized-by;
}

multi sub trait_mod:<is> (Attribute $attr, Str:D :$deserialized-by!) is export
{
    $attr does CustomUnmarshallerMethod;
    $attr.unmarshaller = $deserialized-by;
}


#----------------------------------------------------------------------

role Serializer
{
    multi method serialize(Mu:D $obj --> Blob) {...}

    multi method deserialize(Blob, Mu) {...}
}

role Serializable[Serializer $serializer]
{
     method serialize(--> Blob)
     {
         $serializer.serialize(self)
     }

     method deserialize(Blob $buf, Mu $type = self)
     {
         $serializer.deserialize($buf, $type)
    }
}
