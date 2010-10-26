use HTTP::Session::Store::OnMemory;
use HTTP::Session::State::Cookie;

return +{
    'Plugin::Session' => +{
        store => HTTP::Session::Store::OnMemory->new,
        state => HTTP::Session::State::Cookie->new,
    },
};

