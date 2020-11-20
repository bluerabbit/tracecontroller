# tracecontroller

A Rake task that helps you find missing callbacks in your Rails app.

## Install

Put this line in your Gemfile:
```
gem 'tracecontroller'
```

Then bundle:
```
% bundle
```

## Usage

Create a .tracecontroller.yaml or .tracecontroller.yml file in your root directory.

```yaml
- path: ^/api
  superclass: API::BaseController
  actions:
    - before:
        - require_login_for_api

- path: ^/
  actions:
    - before:
        - require_login
  ignore_classes:
    - ^ActionMailbox|^ActiveStorage|^Rails
    - ^API
```

Just run the following command in your Rails app directory.

```
% rake tracecontroller
```

If you want the rake task to fail when errors are found.

```
% FAIL_ON_ERROR=1 rake tracecontroller
```

## Copyright

Copyright (c) 2020 Akira Kusumoto. See MIT-LICENSE file for further details.
