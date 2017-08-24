# Dock Change Log

## master (unreleased)

* Fix port_taken_on_localhost method for OSX machines

## 1.4.6 (2017-05-11)

* Update README with startup_services configuration allowing users to specify
  which project services to start up when being integrated into a multi-project Dock
  environment.

## 1.4.5 (2017-04-11)

* Modify default container entry command in order to prevent Dock containers
  from exiting following project extensions

## 1.4.4 (2017-04-10)

* Set project repo root to current working directory rather than top level
  git repository root to allow dock to run in git repo subdirs
* Include list of projects currently a part of a dock container within dock
  extension messaging

## 1.4.3 (2017-03-29)

* Change defaults for privileged and pull_latest flags from false to true
* Add startup_services configuration option allowing projects to specify
  which services and variants therein to launch during terraforming of an
  extended container
* Modify extension option to only record compose construction label if
  docker-compose file exists in project repo
* Add image check to extension option to allow base projects to specify
  an image to utilize for Dock development container
* Apply various refactorizations

## 1.4.2 (2017-03-22)

* Hotfix removing docker-compose file verification during extension.
  Technically, functionality should not have been affected with the
  verification in place though it makes sense to remove it.

## 1.4.1 (2017-03-13)

* Add 'transform' option allowing users to fully merge and compose an existing
  extended Dock container
* Download and install docker-compose tool within Dock Dockerfile
* Replace Dock configuration label (i.e. compose/dock.<project>) values with the path
  for each file within the container rather than its contents

## 1.4.0 (2017-02-27)

* Add 'extension' option allowing users to build
  environments consisting of multiple projects/services
* Update container inspection and modification methods to operate
  on either the project default dock container or a different
  container targeted by the user (as a means of maintaining backwards
  compatibility)
* Refactor basic dock run args compilation logic into a
  separate reusable method

## 1.3.1 (2016-11-24)

* Fix `integer expression expected` warning on hosts running Bash 4 or newer

## 1.3.0 (2016-11-23)

* Add `build_context` configuration option allowing the build context
  path/URL to be specified
* Add support for automatically destroying already-existing/running Dock
  containers for a project by specifying the `DOCK_FORCE_DESTROY` environment
  variable (useful in CI environments where containers can get left behind)

## 1.2.0 (2016-11-15)

* Don't set container hostname by default
* Rename `hostname` option to `container_hostname` so it doesn't conflict with
  `hostname` executable

## 1.1.0 (2016-11-09)

* Add `build_flags` configuration option allowing you to specify additional
  arguments to include in the `docker build ...` command
* Rename `run_args` to `run_flags` so naming convention better matches the
  `build_flags` configuration option
* Fix symlink resolution of `dock` executable to not require GNU version of
  `readlink`

## 1.0.0 (2016-10-31)

* Initial release
