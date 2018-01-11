use Data::MessagePack;
use Serializer::Hash;

class Serializer::MessagePack does Serializer::Hash
{
    multi method serialize(%obj --> Blob)
    {
        Data::MessagePack::pack(%obj)
    }

    multi method deserialize(Blob $blob, Mu $type)
    {
        samewith Data::MessagePack::unpack($blob), $type
    }
}
