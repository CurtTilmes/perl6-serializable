use v6;

# This is a poor way to use BSON.. just a proof of concept for now..

use BSON::Document;
use Serializer::Hash;

class Serializer::BSON does Serializer::Hash
{
    multi method serialize(%obj --> Blob)
    {
        my $d = BSON::Document.new;
        $d.accept-hash(True);
        $d<data> = %obj;
        $d.encode;
    }

    multi method deserialize(Blob $blob, Mu $type)
    {
        samewith %(BSON::Document.new($blob)<data>.kv), $type;
    }
}
