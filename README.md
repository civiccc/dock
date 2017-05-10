[![Build Status](https://travis-ci.org/brigade/dock.svg?branch=master)](https://travis-ci.org/brigade/dock)

# Dock

`dock` is a tool for defining, building, and running self-contained development
environments inside [Docker](https://www.docker.com/) containers.

* [Installation](#installation)
* [Getting Started](#getting-started)
* [Usage](#usage)
  * [Attach to an already-running container](#attach-to-an-already-running-container)
  * [Destroy an already-running container](#destroy-an-already-running-container)
  * [Run a container in the background](#run-a-container-in-the-background)
  * [Extend an existing container](#extend-an-existing-container)
  * [Terraform an existing container](#terraform-an-existing-container)
  * [Automatically execute a script in a Dock container](#automatically-execute-a-script-in-a-dock-container)
  * [Expose services inside the container on your host](#expose-services-inside-the-container-on-your-host)
* [Configuration](#configuration)
  * [Options](#options)
  * [Helpers](#helpers)
* [Development](#development)
  * [Running Tests](#running-tests)
* [Change Log](#change-log)
* [License](#license)

## Installation

All you need to run `dock` is to have Docker and Bash installed on your system.

### via Homebrew (macOS)

```bash
brew tap brigade/dock
brew install dock
```

You can then upgrade at any time by running:

```
brew upgrade dock
```

### via Bash (Linux/macOS)

You can install/upgrade Dock with this command:

```bash
curl https://raw.githubusercontent.com/brigade/dock/master/script/install-dock | bash
```

It will ask for your sudo password only if necessary.

### Docker for Mac

If you are using [Docker for Mac](https://docs.docker.com/docker-for-mac/),
you need to add `/usr/local/Cellar` (if you installed Dock using Homebrew) or
`/usr/local/bin` (if you installed using the Bash script) to the list of mountable
directories.

This allows Dock to mount itself within the container so you can recursively
execute Dock within Dock containers. You can add the path via
**Preferences** -> **File Sharing**:

<p align="center">
  <img src="https://raw.githubusercontent.com/brigade/dock/master/doc/img/docker-for-mac-file-sharing.png" width="50%" alt="Docker for Mac File Sharing" />
</p>

## Getting Started

You can try out Dock against the Dock repository itself to get a feel for how
it works.

**WARNING**: This will start a privileged container on your machine (in order to
start a Docker daemon within the container, it needs extended privileges).
Proceed at your own risk.

```bash
git clone git://github.com/brigade/dock
cd dock
bin/dock # If you have installed Dock then you can just run `dock`
```

After running `dock` inside the Dock repository, you should be running inside
a Docker container. The environment will look and feel like CentOS 7 because
it is based off of that image (see the corresponding [Dockerfile](Dockerfile)).
Your current directory will be `/workspace` inside that container, and the
contents of that directory will be the Dock repository itself (i.e. the current
project).

```
$ pwd
/workspace
$ ls
Dockerfile LICENSE.md README.md ...
```

Any changes you make to these files will automatically be reflected in the
original repository, and vice versa. This allows you to continue using your
favorite tools and editors to make changes to your project, but actually
run code or tests _inside_ the container to isolate these from the rest of
your system.

## Usage

Run `dock` within your repository by specifying any options followed by the
command you wish to run in the Dock container:

```
cd path/to/repo
dock [options] [command...]
```

If no command is given, Dock will execute the `default_command` defined in your
Dock configuration file. If no `default_command` is specified, the
`ENTRYPOINT`/`CMD` directives defined in the Dockerfile that created the image
Dock is running will dictate which command will be executed.

Option                 | Description
-----------------------|-------------------------------------------------------
`-a`                   | Attach to an already-running Dock container
`-c config-file`       | Path of Dock configuration file to use (default `.dock`)
`-d`                   | Detach/daemonize (run resulting Dock container in the background)
`-e dock-id`           | Extend an existing Dock container (add new project configuration and services)
`-f`                   | Force creation of new container (destroying old one if it exists)
`-h`                   | Display summary of command line options
`-q`                   | Silence Dock-related output (so only output from command run in the container is shown)
`-t dock-id`           | Terraform an existing Dock container (fully compose and merge embedded projects)
`-v`                   | Display version information
`-V`                   | Display verbose version information (for bug reports)

### Attach to an already-running container

Dock is intended to make it easy to manage a _single_ development environment
for a repository, like you would any virtual machine. Thus it *explicitly
prevents* you from running `dock` multiple times in the same project to run
multiple containers for that single project (if you must, you can get around
this by cloning the project into separate directories with different names so
they are assigned different container names by default).

You can however open multiple shells to the same container by attaching to an
already-running Dock container by running `dock -a` in the project directory.

### Destroy an already-running container

If you run `dock` in a repository which already has an associated container
running, you'll prompted to confirm if you would like to destroy the current
container (if there's no interactive shell, Dock will halt with an error).

You can bypass this prompt by setting the environment variable
`DOCK_FORCE_DESTROY=1`. This is useful in CI environments where there is no
interactive shell but you are sure you always want to destroy any lingering
containers.

### Run a container in the background

If you want to have Dock start up isolated services and don't require an active
shell session inside the container, you can start the container in detached
mode.

Run `dock -d` or specify `detach true` in your Dock configuration.

### Extend an existing container

You can run multiple projects within a single `Dock` container in very much the
same way `Dock` runs a single project.

If you run `dock` in a repository and specify a `Dock` container identifier (used
to annotate and distinguish between `Dock` container environments) to extend, `dock`
will add the project src and all associated environment configuration (e.g. volumes,
exposed ports, environment variables) into the `Dock` container represented by the
identifier.

If the specified `Dock` container does not exist, `dock` will create and run a new
`Dock` container based on the configuration of the current project.

```bash

$ cd /<path-to-project>     # step 1
$ dock -e <dock-id>         # step 2
...
SUCCESS: Dock <dock-id> successfully created!
$ cd /<path-to-new-project> # step 3
$ dock -e <dock-id>         # step 4
...
SUCCESS: Dock <dock-id> successfully extended!
```

### Terraform an existing container

Specifying a `-t` flag along with a `Dock` container identifier when running `Dock`
will result in the full composition and merging of the embedded project components
within the container. This option essentially stands up all services and associated
components added to the target `Dock` container using the `extends` options while also
handling the proper identification and deduplication of shared components.

The result of the operation will be a container consistent with running `docker-compose up`
on each docker-compose.yml file associated with all projects embedded within
and obeying [Docker's official docker-compose extension support](https://docs.docker.com/compose/extends/).
```bash

$ dock -t <dock-id>       # step 1
...
SUCCESS: Dock <dock-id> successfully terraformed!
```

### Automatically execute a script in a Dock container

By adding a correct [shebang line](https://en.wikipedia.org/wiki/Shebang_(Unix))
to your script, you can have the script automatically run inside a Dock container.

```bash
#!/usr/local/bin/dock bash
echo "We are in a container!"
```

If you run this in a project with a valid Dock configuration file, the script
will invoke Dock which will start a container using the image defined by the
configuration execute the script using whatever command you passed as the second
argument (`bash` in this case).

Any Dock-related output will go to the standard error stream, but the standard
output stream will contain output from the original script. If you need to
inspect the command's standard error stream and don't want to deal with filtering
out Dock-related output, you can specify the `QUIET` environment variable in order
to silence all Dock-related output. Note that this can potentially be confusing
since if the image has never been built before it may take a while to build,
giving the appearance of nothing happening.

**WARNING**: Never specify more than one argument to the shebang line. Different
operating systems have different restrictions on shebangs. While some allow you
to specify as many as you want, Linux in particular will treat all arguments
after the executable as a single argument. For example, the following code:

```bash
#!/usr/local/bin/dock bash -c 'some command'
...
```

...will treat the shebang line as `/usr/local/bin/dock "bash -c 'some command'"`
(i.e. treating `bash -c 'some command'` as a single argument), which will fail
since there is no such file.

If you need to execute a script with a complicated set of arguments, create
a wrapper script:

```bash
#!/usr/local/bin/dock script/my-wrapper-script
...
```

The wrapper script will be passed the path to the script file as a single
argument. It is up to you to write the script to know how to handle/execute
the file it is given.

### Expose services inside the container on your host

While an important feature offered by Dock is isolating your development
environments from each other (e.g. so that services listening on the same
port don't conflict), it is convenient to be able to expose these ports on
your host so you can easily interact with them using tools installed on
your host.

You can expose/publish a port using the `publish` command in your
configuration:

```bash
publish 3306:3306 # Expose MySQL on the same port on the host
```

Where this differs from the `--publish` flag of `docker run` is that if the
port is already taken by another process on your machine (e.g. another Dock
container for a different project) you'll still be able to start the
container. You'll see a warning letting you know that the port could not
be exposed.

If you really need to expose the service for a given project, stop the
container for the other project so it releases the port, start the project
whose service you want to expose, and then start back up your other project.

Alternatively, you can decide to expose the services to different ports on
the host so they don't conflict.

## Configuration

The Dock configuration file is quite flexible since it's simply sourced as a
Bash script. By default Dock looks for a `.dock` file at the root of your
repository and sources it.

This means anything you can do in Bash you can also do in this script.
Therefore caution is required!

However, this also provides an incredible amount of power. A common use case
is to dynamically change which environment variables are set or volumes are
mounted based on whether you are running in a CI (continuous integration)
testing environment or just a regular development environment.

Dock exposes configuration options and helpers.

### Options

These configuration options can be set in your Dock configuration file.

* [`attach_command`](#attach_command)
* [`build_arg`](#build_arg)
* [`build_context`](#build_context)
* [`build_flags`](#build_flags)
* [`container_hostname`](#container_hostname)
* [`container_name`](#container_name)
* [`default_command`](#default_command)
* [`detach`](#detach)
* [`detach_keys`](#detach_keys)
* [`dockerfile`](#dockerfile)
* [`dock_in_dock`](#dock_in_dock)
* [`env_var`](#env_var)
* [`image`](#image)
* [`optional_env_var`](#optional_env_var)
* [`privileged`](#privileged)
* [`publish`](#publish)
* [`pull_latest`](#pull_latest)
* [`required_env_var`](#required_env_var)
* [`run_flags`](#run_flags)
* [`startup_services`](#startup_services)
* [`volume`](#volume)
* [`workspace_path`](#workspace_path)

#### `attach_command`

Command to execute when attaching to a container via `dock -a`. By default this
is just `bash`.

```bash
attach_command gosu app_user
```

**WARNING**: You must split the command into individual arguments in order for
them to be executed correctly. This means if you have a single argument with
whitespace you'll need to wrap it in quotes or escape it:

```bash
attach_command echo "This is a single argument"
attach_command echo These are multiple separate arguments
```

#### `build_arg`

Specify an additional build argument to pass to the `docker build` command that
Dock will execute when building the Dockerfile specified by the `dockerfile`
option. Ignored if you have only specified an `image` rather than a `dockerfile`,
as no building is done in such case.

```bash
build_arg MY_ARG "some value"
```

#### `build_context`

Specify the path or URL to use for the build context of the `docker build`
command that Dock will execute when building the Dockerfile.  Ignored if you
have only specified an `image` rather than a `dockerfile`.

```bash
build_context path/in/repo

build_context https://example.com/context.tar.gz
```

See the [`docker build`](https://docs.docker.com/engine/reference/commandline/build)
documentation for details on how the build context and Dockerfile paths are handled.

#### `build_flags`

Specify additional arguments for the `docker build` command that Dock will
execute when building the Dockerfile specified by the `dockerfile` option.
Ignored if you have only specified an `image` rather than a `dockerfile`, as
no building is done in such case.

**Note**: This is not exclusively for the `--build-arg` flag that allows you to
specify build-time variables (use the `build_arg` option instead). It allows you
to specify _any_ flag that `docker build` accepts, e.g. `--memory`, `--no-cache`,
etc.

```bash
build_flags --no-cache
```

#### `container_hostname`

Specifies an explicit hostname for the container.

```bash
container_hostname "$(container_name).test.com"
```

#### `container_name`

Specifies the name to give the Dock container. Default is the directory name of
the repository followed by "-dock", e.g. `my-project-dock`.

The container name is what Dock uses to determine if the container is already
running.

```bash
container_name my-container-name
```

#### `default_command`

Specifies a default command to run if no command is explicitly given.

You should ideally always have a default command specified so that a user who
knows nothing about your repository can simply run `dock` to get started.

```bash
default_command script/start-services
```

**WARNING**: You must split the command into individual arguments in order for
them to be executed correctly. This means if you have a single argument with
whitespace you'll need to wrap it in quotes or escape it:

```bash
default_command echo "This is a single argument"
default_command echo These are multiple separate arguments
```

#### `detach`

Specifies whether the Dock container should run in the background (e.g. the
`--detach` flag of `docker run`).

You can re-attach to a detached Dock container by running `dock -a`.

```bash
detach true
```

#### `detach_keys`

Specifies the key sequence to detach from the container.

Dock changes this sequence from the default `ctrl-p,p` to `ctrl-x,x`. This
makes the `ctrl-p` readline shortcut for cycling through previous commands
work as expected without needing to type `ctrl-p` twice, which is useful
when you are running a shell in the container.

This is almost certainly what you want, but `detach_keys` is available if you
want to change it to some other sequence.

#### `dockerfile`

Specify path to the Dockerfile to build into an image used by the Dock
container. If a relative path is given, this will be relative to the
repository root directory (even if you have specified a custom
[`build_context`](#build_context), the path is always relative to the root
of the repository).

Cannot specify `dockerfile` and `image` options in the same configuration.

```bash
dockerfile Dockerfile
```

#### `dock_in_dock`

Specify whether to allow Dock to create containers within a Dock container.
Default is `false`, and this is almost always what you want.

The Dock project itself needs to test the creation of Dock containers within
a Dock container, so it enables this feature.

```bash
dock_in_dock true
```

#### `env_var`

Specifies an environment variable name and value to be set inside the
container.

```bash
env_var MY_ENV_VAR "my value"
```

#### `image`

If `dockerfile` is specified, defines the image name to tag the build with.

Otherwise this specifies the image used to create the container.

```bash
image centos:7.2.1511
```

#### `optional_env_var`

Specifies the name of an environment variable which is included in the
container environment if defined in the context in which `dock` is run.
If not defined, it is ignored and no value is set inside the container.

This is a way of safely declaring which environment variables you want
to "inject" from your host into the Dock container.

```bash
optional_env_var MY_OPTIONAL_ENV_VAR
```

#### `privileged`

Whether to run the container with elevated privileges. Defaults to `false`.

```bash
privileged true
```

#### `publish`

Expose a port inside the Dock container to the host. Useful if you want to
make it easier for developers to connect to services inside the Dock container
using tools installed on their host machine.

If another process on the host has already bound to the port, Dock will display
a warning but will otherwise ignore the error, since you will still be able to
access the service from inside the container.

The format of the port specification is the same as the `-p`/`--publish` flag
of the `docker run` command (`[host-ip:][host-port:]container-port`).

```bash
# Expose MySQL
publish "3306:3306"
```

#### `pull_latest`

Specifies whether Docker should always attempt to pull the latest version of
an image/tag to ensure it is up to date. Default is `false`.

```bash
pull_latest true
```

#### `required_env_var`

Specifies the name of an environment variable that must be defined.
If not defined, Dock will halt with an error message.

```bash
required_env_var MY_REQUIRED_ENV_VAR
```

#### `run_flags`

Specify additional arguments for the `docker run` command that Dock will
execute.

Most common flags are configured via the various options allowed in the Dock
configuration, e.g. `env_var`, `volume`, etc. However, for special cases
this is provided to allow you to specify additional flags.

```bash
run_flags --memory 1g
```

#### `startup_services`

Services to startup when terraforming a multi-project, integrated and self-contained Dock development environment, as defined within a project's docker-compose.yml.

```bash
startup_services "my_service mysql"
```

#### `volume`

Specify a volume or bind mount.

```bash
# Mount /var/lib/docker directory in the container on the host file system.
# Destroyed on container shutdown. Useful if you are using a container file
# system like OverlayFS and want to perform a lot of writes with the
# performance of the underlying host file system.
volume "/var/lib/docker"

# Create a data volume named "${container_name}_docker" which store the
# contents of the container's /var/lib/docker directory. Will not be destroyed
# when the container is shutdown/destroyed.
volume "${container_name}_docker:/var/lib/docker"

# Mount a file/directory on the host file system at a particular location in
# the container. Use the ${repo_root} variable so you reference a path that
# will exist regardless of the location of your repository.
volume "${repo_root}/script/my-script:/usr/bin/my-script"
```

#### `workspace_path`

Define the path in the container that the repository will be mounted at.
Default is `/workspace`.

```bash
workspace_path /my-custom-dir
```

### Helpers

Dock defines a number of helper functions which may be useful when writing your
configuration file.

**WARNING**: Bash variables and functions are referenced differently. Since
these helpers are all functions, always use `$(...)` to include the output of a
function in a string, e.g.:

```bash
volume "$(container_name)_docker:/var/lib/docker"
```

* [`ask`](#ask)
* [`detach`](#detach)
* [`group_id`](#group_id)
* [`container_hostname`](#container_hostname)
* [`interactive`](#interactive)
* [`linux`](#linux)
* [`mac_os`](#mac_os)
* [`privileged`](#privileged)
* [`repo_path`](#repo_path)
* [`user_id`](#user_id)
* [`workspace_path`](#workspace_path)

#### `ask`

Asks a user for input. Uses the default answer if we're not running in
an interactive context (as specified by `interactive`).

All arguments must be specified.

```bash
ask "Are you sure? (y/n)" n variable_to_store_answer_in
```

#### `container_hostname`

Outputs the explicit hostname that will be assigned to the container, if one
was specified via `container_hostname "some.name"`. Otherwise it returns
a non-zero exit status.

#### `container_name`

Outputs the name of the Docker container that Dock will create.

#### `detach`

Returns whether container will be detached on startup.

Returns zero exit status (success) if yes.

#### `group_id`

Group ID of the user that ran the Dock command.

#### `interactive`

Whether we're running Dock in an interactive context where a human
can provide input (e.g. standard input is a TTY).

Returns zero exit status (success) if yes.

#### `linux`

Whether the host is running Linux.

Returns zero exit status (success) if yes.

#### `mac_os`

Whether the host is running macOS.

Returns zero exit status (success) if yes.

#### `privileged`

Returns whether the container will be started with extended privileges.

Returns zero exit status (success) if yes.

#### `repo_path`

Path to repository root on the host system.

#### `user_id`

User ID of the user that ran the Dock command.

#### `workspace_path`

Directory in the container that the repository will be mounted at.

Outputs the absolute path.

## Development

Hacking on Dock is easy thanks to the fact that it is run within a Dock
container! Provided you have Docker and Bash installed on your system, working
on Dock is as easy as running `bin/dock` from the root of the repository.

### Running Tests

Tests can be run by executing:

```bash
bin/test
```

...from the root of the repository. This will start a Dock container and run
all tests, which are written in Bash using [Bats](https://github.com/sstephenson/bats).

To run a specific test or set of tests, execute:

```bash
bin/test test/path/to/test.bats test/path/to/another.bats
```

## Change Log

If you're interested in seeing a summarized list of changes between each version
of Dock, see the [Dock Change Log](CHANGELOG.md)

## License

Dock is released under the [Apache 2.0 license](LICENSE).
