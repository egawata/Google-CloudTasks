requires 'perl', '5.008001';

requires 'Mouse';
requires 'WWW::Google::Cloud::Auth::ServiceAccount';
requires 'LWP::UserAgent';
requires 'HTTP::Request';
requires 'URI';
requires 'JSON::XS';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Deep';
    requires 'Test::Exception';
    requires 'Time::HiRes';
};
