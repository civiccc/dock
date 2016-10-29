# Dock

`dock` is a tool for defining, building, and running development environments
inside [Docker](https://www.docker.com/) containers.

* [Installation](#installation)
* [Getting Started](#getting-started)
* [Usage](#usage)
* [Configuration](#configuration)
  * [Options](#options)
  * [Helpers](#helpers)
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

## Getting Started

You can try out Dock against the Dock repository itself to get a feel for how
it works.

```bash
git clone git://github.com/brigade/dock
cd dock
bin/dock # If you have installed Dock then you can just run `dock`
```

After running `dock` inside the Dock repository, you should be running inside
a Docker container. Your current directory will be `/repo` inside that
container, and the contents of that directory will be the Dock repository
itself (i.e. the current project).

```
$ pwd
/repo
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

If no command is given, Dock will execute the default `command` defined in your
Dock configuration file, or otherwise error telling you no command was given.

Option                 | Description
-----------------------|-------------------------------------------------------
`-a`                   | Attach to an already-running Dock container
`-c config-file`       | Path of Dock configuration file to use (default `.dock`)
`-d`                   | Detach/daemonize (run resulting Dock container in the background)
`-f`                   | Force creation of new container (destroying old one if it exists)

### Opening multiple shells in a container

Dock is intended to make it easy to manage a _single_ development environment
for a repository, like you would any virtual machine. Thus it *explicitly
prevents* you from running `dock` multiple times to run multiple containers.

You can however open multiple shells to the same container by attaching to an
already-running Dock container with `dock -a`.

### Running a container in the background

If you want to have Dock start up isolated services and don't require an active
shell session inside the container, you can start the container in detached
mode.

Run `dock -d` or specify `detach true` in your Dock configuration.

## Configuration

The Dock configuration file is quite flexible given it's simply sourced as a
Bash script. By default Dock looks for a `.dock` file at the root of your
repository.

### Options

These configuration options can be set in your Dock configuration file.

* [`attach_command`](#attach_command)
* [`container_name`](#container_name)
* [`default_command`](#default_command)
* [`detach`](#detach)
* [`dockerfile`](#dockerfile)
* [`env_var`](#env_var)
* [`image`](#image)
* [`optional_env`](#optional_env)
* [`privileged`](#privileged)
* [`publish`](#publish)
* [`pull_latest`](#pull_latest)
* [`required_env`](#required_env)
* [`volume`](#volume)
* [`workspace_path`](#workspace_path)

#### `attach_command`

Command to execute when attaching to a container via `dock -a`. By default this
is just `bash`.

```bash
attach_command gosu app_user
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

#### `detach`

Specifies whether the Dock container should run in the background (e.g. the
`--detach` flag of `docker run`).

You can re-attach to a detached Dock container by running `dock -a`.

```bash
detach true
```

#### `dockerfile`

Specify path to the Dockerfile to build into an image used by the Dock
container. If a relative path is given, this will be relative to the
repository root directory.

Cannot specify `dockerfile` and `image` options in the same configuration.

```bash
dockerfile Dockerfile
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
an image/tag to ensure it is up to date. Default is `true`.

```bash
pull_latest true
```

#### `required_env_var`

Specifies the name of an environment variable that must be defined.
If not defined, Dock will halt with an error message.

```bash
required_env_var MY_REQUIRED_ENV_VAR
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
Default is `/repo`.

```bash
workspace_path /my-custom-dir
```

### Helpers

Dock defines a number of helper functions which may be useful when writing your
configuration file.

*WARNING*: Bash variables and functions are referenced differently. Since these
helpers are all functions, always use `$(...)` to include the output of a
function in a string, e.g.:

```bash
volume "$(container_name)_docker:/var/lib/docker"
```

* [`ask`](#ask)
* [`group_id`](#group_id)
* [`interactive`](#interactive)
* [`linux`](#linux)
* [`mac_os`](#mac_os)
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

#### `container_name`

Outputs the name of the Docker container that Dock will create.

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

#### `repo_path`

Path to repository root on the host system.

#### `user_id`

User ID of the user that ran the Dock command.

#### `workspace_path`

Directory in the container that the repository will be mounted at.

Outputs the absolute path.

## License

Dock is released under the [MIT license](LICENSE.md).
