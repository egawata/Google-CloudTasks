# NAME

Google::CloudTasks - Perl client library for the Google CloudTasks API.

# SYNOPSIS

    use Google::CloudTasks;

    my $client = Google::CloudTasks->client(
        version => 'v2',
        credentials_path => '/path/to/credentials.json',
    );

    #  Create task
    my $project_name = 'myproject';
    my $queue_name = 'myqueue';
    my $parent = "/projects/$project_name/queues/$queue_name";

    my $task = {
        name => 'mytask-01234567',
        appEngineHttpRequest => {
            relativeUri => '/do_task',
        },
    }
    my $ret = $client->create_task($parent, $task);

# DESCRIPTION

Google::CloudTasks https://cloud.google.com/tasks/docs/reference/rest/

This is a Perl client library for the Google CloudTasks API (_unofficial_).

## AUTHENTICATION

A service account with appropriate roles is required. You need to download JSON file and specify `credentials_path`.

# METHODS

All methods handle raw hashref (or arrayref of hashref), rather than objects.

## Create a client

    my $client = Google::CloudTasks->client(
        version => 'v2',
        credentials_path => '/path/to/credentials.json',
    );

`version` is an API version. `credentials_path` is a path to a service account JSON file.

## Location

Refer the detailed representation of location at L<>

### get\_location

Gets information about a location.

    my $location = $client->get_location("/projects/$PROJECT_ID/locations/$LOCATION_ID");

### list\_locations

Lists information about all locations under project.

    my $ret = $client->list_locations("/projects/$PROJECT_ID");
    my $locations = $ret->{locations};

## Queue

Refer the detailed representation of queue at [https://cloud.google.com/tasks/docs/reference/rest/v2/projects.locations.queues#Queue](https://cloud.google.com/tasks/docs/reference/rest/v2/projects.locations.queues#Queue)

### create\_queue

Creates a queue.

    my $queue = {
        name => 'queue-name',
    };
    my $created = $client->create_queue("/projects/$PROJECT_ID/locations/$LOCATION_ID", $queue);

### delete\_queue

Deletes a queue.

    $client->delete_queue("/projects/$PROJECT_ID/locations/$LOCATION_ID/queues/$QUEUE_ID")

### get\_queue

Gets information of a queue.

    my $queue = $client->get_queue("/projects/$PROJECT_ID/locations/$LOCATION_ID/queues/$QUEUE_ID");

### list\_queues

Lists information of all queues.

    my $ret = $client->list_queues("/projects/$PROJECT_ID/locations/$LOCATION_ID");
    my $queues = $ret->{queues};

### patch\_queue

Updates a queue.

    my $queue = {
        retryConfig => {
            maxAttempts => 5,
        },
    };
    my $update_mask = { updateMask => 'retryConfig.maxAttempts' };
    my $updated = $client->patch_queue(
        "/projects/$PROJECT_ID/locations/$LOCATION_ID/queues/$QUEUE_ID",
        $queue,
        $update_mask,   # optional
    );

### pause\_queue

Pauses a queue.

    my $queue = $client->pause_queue("/projects/$PROJECT_ID/locations/$LOCATION_ID/queues/$QUEUE_ID");

### resume\_queue

Resumes a queue.

    my $queue = $client->resume_queue("/projects/$PROJECT_ID/locations/$LOCATION_ID/queues/$QUEUE_ID");

## Task

Refer the detailed representation of task at L<>

### create\_task

Creates a task.

    my $task = {
        name => 'task-123456,
        appEngineHttpRequest => {
            relativeUri => '/path',
        },
    };
    my $created = $client->create_task(
        "/projects/$PROJECT_ID/locations/$LOCATION_ID/queues/$QUEUE_ID",
        $task
    );

### delete\_task

Deletes a task.

    $client->delete_task("/projects/$PROJECT_ID/locations/$LOCATION_ID/queues/$QUEUE_ID/tasks/$TASK_ID");

### get\_task

Gets information of a task.

    my $task = $client->get_task("/projects/$PROJECT_ID/locations/$LOCATION_ID/queues/$QUEUE_ID/tasks/$TASK_ID");

### list\_tasks

Lists information of all tasks.

    my $ret = $client->list_tasks("/projects/$PROJECT_ID/locations/$LOCATION_ID/queues/$QUEUE_ID");
    my $tasks = $ret->{tasks};

### run\_task

Runs a task.

    my $ret = $client->run_task("/projects/$PROJECT_ID/locations/$LOCATION_ID/queues/$QUEUE_ID/tasks/$TASK_ID");

# TODO

`Queue.getIamPolicy`

`Queue.setIamPolicy`

`Queue.testIamPermissions`

# LICENSE

Copyright (C) egawata.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

egawata <egawa.takashi@gmail.com>

# POD ERRORS

Hey! **The above document had some coding errors, which are explained below:**

- Around line 75:

    An empty L<>

- Around line 152:

    An empty L<>
