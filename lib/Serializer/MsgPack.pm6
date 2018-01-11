use MsgPack;
use Serializer::Hash;

class Serializer::MsgPack does Serializer::Hash
{
    multi method serialize(%obj --> Blob)
    {
        MsgPack::pack(%obj)
    }

    multi method deserialize(Blob $blob, Mu $type)
    {
        samewith MsgPack::unpack($blob), $type
    }
}
