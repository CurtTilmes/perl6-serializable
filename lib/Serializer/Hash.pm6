use v6;

use Serializable;

role Serializer::Hash does Serializer
{
    multi method serialize(Mu:D $obj --> Blob)
    {
        my %attrs;

        my %local-attrs = $obj.^attributes(:local)
                              .map({ $_.name => $_.package });

        for $obj.^attributes -> $attr
        {
            next if %local-attrs{$attr.name}:exists &&
                    !(%local-attrs{$attr.name} === $attr.package);

            if $attr.has_accessor
            {
                my $name = $attr.name.substr(2);
                my $value = $attr.get_value($obj);
                %attrs{$name} = $attr ~~ CustomMarshaller
                    ?? $attr.marshal($value, $obj)
                    !! $value;
            }

        }

        samewith %attrs
    }

    multi method deserialize(%attrs is copy, Mu $type)
    {
        my %local-attrs = $type.^attributes(:local)
                               .map({ $_.name => $_.package });

        for $type.^attributes -> $attr
        {
            next if %local-attrs{$attr.name}:exists &&
                !(%local-attrs{$attr.name} === $attr.package);

            my $data-name = $attr.name.substr(2);
            if %attrs{$data-name}:exists && $attr ~~ CustomUnmarshaller
            {
                %attrs{$data-name} = $attr.unmarshal(%attrs{$data-name},
                                                     $attr.type);
            }
        }

        $type.new(|%attrs)
    }

}
