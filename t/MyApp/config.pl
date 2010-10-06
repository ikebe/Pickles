use HTTP::Session::Store::OnMemory;
use HTTP::Session::State::Cookie;

return +{
    Plugin::Session => {
        state => 'Cookie',
    },
    TestValue => 1,
    View => {
        TEMPLATE_EXTENSION => '.html',
    },
    'Plugin::Session' => +{
        store => HTTP::Session::Store::OnMemory->new,
        state => HTTP::Session::State::Cookie->new,
    },
};

