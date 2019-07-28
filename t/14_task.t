use strict;
use warnings;
use utf8;

use lib qw/lib/;
use Test::More;
use Test::Exception;
use Test::Deep;
use Time::HiRes;
use MIME::Base64;
use Google::CloudTasks;

BEGIN {
    unless (defined $ENV{GOOGLE_APPLICATION_CREDENTIALS} && defined $ENV{PROJECT_ID} && defined $ENV{LOCATION_ID}) {
        Test::More::plan(skip_all => 'This test needs GOOGLE_APPLICATION_CREDENTIALS and PROJECT_ID and LOCATION_ID')
    }
}

my $client = Google::CloudTasks->client(
    credentials_path => $ENV{GOOGLE_APPLICATION_CREDENTIALS},
    is_debug => 0,
);
my $queue_id = sprintf('ct-queue-test-%f-%d', Time::HiRes::time(), int(rand(10000)));
$queue_id =~ s/\./-/g;
my $parent_of_queue = "projects/$ENV{PROJECT_ID}/locations/$ENV{LOCATION_ID}";
my $parent = "$parent_of_queue/queues/$queue_id";
my $queue = {
    name => $parent,
};
$client->create_queue($parent_of_queue, $queue);

my $task_id = sprintf('ct-task-test-%f-%d', Time::HiRes::time(), int(rand(10000)));
$task_id =~ s/\./-/g;
my $task_name = "$parent/tasks/$task_id";

subtest 'create' => sub {
    my $body = encode_base64('{"name": "TaskTest"}');
    chomp($body);

    my $task = +{
        name => $task_name,
        appEngineHttpRequest => {
            relativeUri => '/path',
            headers => {
                'Content-Type' => 'application/json',
            },
            body => $body,
        },
    };
    my $ret;
    lives_ok {
        $ret = $client->create_task($parent, $task, {});
    };
    is $ret->{name}, $task_name;
};

subtest 'get' => sub {
    my $ret;
    lives_ok {
        $ret = $client->get_task($task_name);
    };
    is $ret->{name}, $task_name;
};

subtest 'list' => sub {
    my $ret;
    lives_ok {
        $ret = $client->list_tasks($parent);
    };
    cmp_deeply $ret->{tasks}, supersetof(
        superhashof(
            +{
                name => $task_name,
            }
        ),
    );
};

subtest 'run' => sub {
    my $before = $client->get_task($task_name);
    my $ret;
    lives_ok {
        $ret = $client->run_task($task_name);
    };
    is $ret->{dispatchCount}, $before->{dispatchCount} + 1;
};

subtest 'delete' => sub {
    my $ret;
    lives_ok {
        $ret = $client->delete_task($task_name);
    };
    is_deeply $ret, +{};
};

$client->delete_queue($parent);

done_testing;
