use JSON::Fast;
use Serializer::Hash;

class Serializer::JSON does Serializer::Hash
{
    multi method serialize(%obj --> Blob)
    {
        to-json(%obj).encode
    }

    multi method deserialize(Blob $blob, Mu $type)
    {
        samewith from-json($blob.decode), $type;
    }
}
