use YAMLish;
use Serializer::Hash;

class Serializer::YAMLish does Serializer::Hash
{
    multi method serialize(%obj --> Blob)
    {
        save-yaml(%obj).encode
    }

    multi method deserialize(Blob $blob, Mu $type)
    {
        samewith load-yaml($blob.decode), $type
    }
}
