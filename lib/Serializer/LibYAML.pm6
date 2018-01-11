use LibYAML;
use Serializer::Hash;

class Serializer::LibYAML does Serializer::Hash
{
    multi method serialize(%obj --> Blob)
    {
        dump-yaml(%obj).encode
    }

    multi method deserialize(Blob $blob, Mu $type)
    {
        samewith load-yaml($blob.decode), $type;
    }
}
