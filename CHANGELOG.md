# Dock Change Log

## master (unreleased)

* Add dock environment 'extension' option allowing users to build
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
