# Dock Change Log

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
