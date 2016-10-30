# Dock

`dock` is a tool for defining, building, and running self-contained development
environments inside [Docker](https://www.docker.com/) containers.

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

### Docker for Mac

If you are using [Docker for Mac](https://docs.docker.com/docker-for-mac/),
you need to add `/usr/local/bin` to the list of mountable directories. This
allows Dock to mount itself within the container so you can recursively execute
scripts with Dock shebang lines without creating nested Dock containers. You
can add the path via **Preferences** -> **File Sharing**:

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
`-f`                   | Force creation of new container (destroying old one if it exists)

### Opening multiple shells in a container

Dock is intended to make it easy to manage a _single_ development environment
for a repository, like you would any virtual machine. Thus it *explicitly
prevents* you from running `dock` multiple times in the same project to run
multiple containers for that project.

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
* [`detach_keys`](#detach_keys)
* [`dockerfile`](#dockerfile)
* [`dock_in_dock`](#dock_in_dock)
* [`env_var`](#env_var)
* [`hostname`](#hostname)
* [`image`](#image)
* [`optional_env_var`](#optional_env_var)
* [`privileged`](#privileged)
* [`publish`](#publish)
* [`pull_latest`](#pull_latest)
* [`required_env_var`](#required_env_var)
* [`run_args`](#run_args)
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
repository root directory.

Cannot specify `dockerfile` and `image` options in the same configuration.

```bash
dockerfile Dockerfile
```

#### `dock_in_dock`

Specify whether to allow Dock to created containers within a Dock container.
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

#### `hostname`

Specifies the hostname for the container. Defaults to the container name.

```bash
hostname "$(container_name).test.com"
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

#### `run_args`

Specify additional arguments for the `docker run` command that Dock will
execute.

Most common flags are configured via the various options allowed in the Dock
configuration, e.g. `env_var`, `volume`, etc. However, for special cases
this is provided to allow you to specify additional flags.

```bash
run_args --cpu-shares 1024
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
