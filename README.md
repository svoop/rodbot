[![Version](https://img.shields.io/gem/v/rodbot.svg?style=flat)](https://rubygems.org/gems/rodbot)
[![Tests](https://img.shields.io/github/actions/workflow/status/svoop/rodbot/test.yml?style=flat&label=tests)](https://github.com/svoop/rodbot/actions?workflow=Test)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/svoop/rodbot.svg?style=flat)](https://codeclimate.com/github/svoop/rodbot/)
[![Donorbox](https://img.shields.io/badge/donate-on_donorbox-yellow.svg)](https://donorbox.org/bitcetera)

<img src="https://github.com/svoop/rodbot/raw/main/doc/rodbot.avif" alt="Rodbot" height="125" align="left">

# Rodbot

Minimalistic yet polyglot framework to build chat bots on top of a Roda backend for chatops and fun.

<br clear="all">

<b>⚠️ RODBOT IS UNDER CONSTRUCTION AND NOT FIT FOR ANY USE YET.<br>🚧 Active development is underway, the first release should be ready soonish.</b>

* [Homepage](https://github.com/svoop/rodbot)
* [API](https://rubydoc.info/gems/rodbot)
* Author: [Sven Schwyn - Bitcetera](https://bitcetera.com)

## Table of Contents

[Install](#label-Install) <br>
[Anatomy](#label-Anatomy) <br>
&emsp;&emsp;&emsp;[App Service](#label-App-Service) <br>
&emsp;&emsp;&emsp;[Relay Services](#label-Relay-Services) <br>
&emsp;&emsp;&emsp;[Schedule Service](#label-Schedule-Service) <br>
[CLI](#label-CLI) <br>
[Routes and Commands](#label-Routes-and-Commands) <br>
[Database](#label-Database) <br>
[Credentials](#credentials) <br>
[Plugins](#label-Plugins) <br>
[Environment Variables](#label-Environment-Variables) <br>
[Development](#label-Development) <br>

## Install

### Security

This gem is [cryptographically signed](https://guides.rubygems.org/security/#using-gems) in order to assure it hasn't been tampered with. Unless already done, please add the author's public key as a trusted certificate now:

```
gem cert --add <(curl -Ls https://raw.github.com/svoop/rodbot/main/certs/svoop.pem)
```

### Generate New Bot

Similar to other frameworks, generate the files for your new bot as follows:

```
gem install rodbot --trust-policy MediumSecurity
rodbot new my_bot
cd my_bot
```

For the bot to be useful at all, you should choose one of the supported [relay service plugins](#label-Plugins). Say, you'd like to interact via Matrix:

```
bundle config set --local with matrix
bundle install
```

(Please refer to the [Matrix plugin README](https://rubydoc.info/github/svoop/rodbot/file/lib/rodbot/plugins/matrix/README.matrix.md) for more on how to configure and authorise this relay service.)

You're all set, let's have a look at what Rodbot can do for you:

```
bundle exec rodbot --help
```

## Anatomy

The bot consists of three kinds of services interacting with one another:

```
RODBOT                                                            EXTERNAL
╭╴ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ╶╮
╷ ╭──────────────────╮  <─────>  ╭──────────────────╮       ╷
╷ │ APP              │  <───╮    │ RELAY - Matrix   ├╮  <──────>  [1] Matrix
╷ ╰──────────────────╯  <─╮ │    ╰┬─────────────────╯├╮  <──┼──>  [1] simulator
╷                         │ │     ╰┬─────────────────╯│   <────>  [1] ...
╷                         │ │      ╰──────────────────╯     ╵
╷                         │ │                               ╵
╷                         │ │     ╭──────────────────╮      ╵
╷                         │ ╰──>  │ SCHEDULE         │  <───┼───  [2] clock
╷                         │       ╰──────────────────╯      ╷
╷                         │                                 ╷
╷                         ╰─────────────────────────────────────  [3] webhook caller
╰╴ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ╶╯
```

### App Service

The **app service** is a [Roda app](https://roda.jeremyevans.net) where the real action happens. It acts on and responds to HTTP requests from:

* commands forwarded by **relay services**
* timed events triggered by the **schedule service**
* third party webhook calls e.g. from GitLab, GitHub etc

#### Commands

All top level GET requests such as `GET /foobar` are commands and therefore are accessible by relays, for instance using `!foobar` on Matrix.

Responses have to be either of the following content types:

* `text/plain; charset=utf-8`
* `text/markdown; charset=utf-8`

Please note that the Markdown might get stripped on communication networks which feature only limited or no support for Markdown.

The response may contain special tags which have to be replace appropriately by the corresponding **relay service**:

Tag | Replaced with
----|--------------
`[[SENDER]]` | Mention the sender of the command.

#### Other Routes

All higher level requests such as `GET /foo/bar` are not accessible by relays. Use them to implement other aspects of your bot such as webhooks or schedule tasks.

### Relay Services

The **relay service** act as glue between the **app service** and external communication networks such as Matrix.

Each relay service does three things:

* **Proactive:** It creates and listens to a local TCP socket. Plain text or Markdown sent to this socket is forwarded as a message to the corresponding communication network. This text may have multiple lines, use the EOT character (`\x04` alias Ctrl-D) to mark the end.
* **Reactive:** It reads messages, detects commands usually beginning with a `!`, forwards them to the **app service** and writes the HTTP response back as a message to the communication network.
* **Test:** It detects the `!ping` command and replies with "pong" *without* hitting the **app service**.

You can simulate such a communication network locally:

```
rodbot simulator
```

Enter the command `!pay EUR 123` and you see the request `GET /pay?argument=EUR+123` hitting the **app service**.

### Schedule Service

The **schedule service** is a [Clockwork process](https://github.com/Rykian/clockwork) which triggers HTTP requests to the **app service** based on timed events.

## CLI

The `rodbot` CLI is the main tool to manage your bot. For a full list of functions:

```
rodbot --help
```

### Starting and Stopping Services

While working on the app service, you certainly want to try routes:

```
rodbot start app
```

This starts the server in the current terminal. You can set breakpoints with `binding.irb`, however, if you prefer a real debugger:

```
rodbot start app --debugger
```

This requires the [debug gem](https://rubygems.org/gems/debug) and adds the ability to set breakpoints with `debugger`.

You can also start single services in the background:

```
rodbot start app --daemonize
```

However, it's not particularly useful unless you start all services at once. In fact, it's even mandatory in this case, so you don't have to mentioe `--daemonize` explicitly:

```
rodbot start
```

Finally, to start all running Rodbot services:

```
rodbot stop
```

### Deployment

There are many ways to deploy Rodbot on different hosting services. For the most common scenarios, you can generate the deployment configuration:

```
rodbot deploy docker
```

In case you prefer to split each service into its own container:

```
rodbot deploy docker --split
```

## Routes and Commands

Adding new tricks to your bot boils down to adding routes to the app service which is powered by Roda, a simple yet very powerful framework for web applications: Easy to learn (like Sinatra) but really fast and efficient. Take a minute and [get familiar with the basics of Roda](http://roda.jeremyevans.net/).

Rodbot relies on [MultiRun](https://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/MultiRun.html) to spread routes over more than one routing file. This is necessary for Rodbot plugins but is entirely optional for your own routes.

⚠️ At this point, keep in mind that any routes at the root level like `/pay` or `/calculate` can be accessed via chat commands such as `!pay` and `!calculate`. Routes which are nested further down, say, `/myapi/users` are off limits and should be used to trigger schedule events and such. Make sure you don't accidentally add routes to the root level you don't want people to access via chat commands, not even by accident.

To add a simple "Hello, World!" command, all you have to do is add a route `/hello`. A good place to do so is `app/routes/hello.rb`:

```ruby
module Routes
  class Hello < App

    route do |r|

      # GET /hello
      r.root do
        response['Content-Type'] = 'text/plain; charset=utf-8'
        'Hello, World!'
      end

    end

  end
end
```

To try, start the app service with `rodbot start app` and fire up the simulator with `rodbot simulator`:

```
rodbot> !hello
Hello, World!
```

Try to keep these route files thin and extract the heavy lifting into service classes. Put those into the `lib` directory where they will be autoloaded by Zeitwerk.

## Database

Your bot might be happy dealing with every command as an isolated event. However, some implementations require data to be persisted between requests. A good example is the [OTP plugin](https://rubydoc.info/github/svoop/rodbot/file/lib/rodbot/plugins/otp/README.otp.md) which needs a database to assure each one-time password is accepted once only.

Rodbot implements a very simple key/value database which is completely optional and supports a few different backends.

### Redis

For the Redis backend to work, you have to install the corresponding Bundler group:

```
bundle config set --local with redis
bundle install
```

Then set the connection URL in `config/rodbot.rb`:

```ruby
db 'redis://localhost:6379/10'
```

### Hash

The Hash backend is not thread-safe and therefore shouldn't be used in production. To use it, simply add the following to `config/rodbot.rb`:

```ruby
db 'hash'
```

### Write and Read Data

With this in place, you can access the database with `Rodbot.db`:

```ruby
Rodbot.db.flush                                        # => Rodbot::Db

Rodbot.db.set('foo') { 'bar' }                         # => 'bar'
Rodbot.db.get('foo')                                   # => 'bar'
Rodbot.db.scan('*')                                    # => ['foo']
Rodbot.db.delete('foo')                                # => 'bar'
Rodbot.db.get('foo')                                   # => nil

Rodbot.db.set('lifetime', expires_in: 1) { 'short' }   # => 'short'
Rodbot.db.get('lifetime')                              # => 'short'
sleep 1
Rodbot.db.get('lifetime')                              # => nil
```

For a few more tricks, see the [Rodbot::Db docs](https://www.rubydoc.info/gems/rodbot/Rodbot/Db.html).

## Credentials

In order not to commit secrets to repositories or environment variables, Rodbot bundles the [dry-credentials](https://rubygems.org/gems/dry-credentials) gem and exposes it via the `rodbot credentials` CLI command. The secrets are then available in your code like `Rodbot.credentials.my_secret` and the encrypted files are written to `config/credentials`.

## Plugins

Rodbot aims to keep its core small and add features via plugins, either built-in or provided by gems.

### Built-In Plugins

Name | Dependencies | Description
-----|--------------|------------
[:matrix](https://rubydoc.info/github/svoop/rodbot/file/lib/rodbot/plugins/matrix/README.matrix.md) | yes | relay service for the [Matrix communication network](https://matrix.org)
[:say](https://rubydoc.info/github/svoop/rodbot/file/lib/rodbot/plugins/say/README.say.md) | no | write proactive messages to communication networks
[:otp](https://rubydoc.info/github/svoop/rodbot/file/lib/rodbot/plugins/otp/README.otp.md) | yes | guard commands with one-time passwords
[:gitlab_webhook](ttps://rubydoc.info/github/svoop/rodbot/file/lib/rodbot/plugins/gitlab_webhook/README.gitlab_webhook.md) | no | event announcements from [GitLab](https://gitlab.com)
[:github_webhook](ttps://rubydoc.info/github/svoop/rodbot/file/lib/rodbot/plugins/github_webhook/README.github_webhook.md) | no | event announcements from [GitHub](https://github.com)
[:hal](https://rubydoc.info/github/svoop/rodbot/file/lib/rodbot/plugins/hal/README.hal.md) | no | feel like Dave (demo)
[:word_of_the_day](ttps://rubydoc.info/github/svoop/rodbot/file/lib/rodbot/plugins/word_of_the_day/README.word_of_the_day.md) | no | word of the day announcements (demo)

You have to install the corresponding Bundler group in case the plugin depends on extra gems. Here's an example for the `:otp` plugin listed above:

```
bundle config set --local with otp
bundle install
```

### How Plugins Work

Given the following `config/rodbot.rb`:

```ruby
plugin :my_plugin do
  color 'red'
end
```

Plugins provide one or more extensions each of which extends one of the services. In order only to spin things up when needed, the plugin may contain the following files:

* `rodbot/plugins/my_plugin/app.rb` – add routes and/or extend Roda
* `rodbot/plugins/my_plugin/relay.rb`  – add a relay
* `rodbot/plugins/my_plugin/schedule.rb` – add schedules to Clockwork

Whenever a service boots, the corresponding file is required.

In order to keep these plugin files slim, you should extract functionality into service classes. Just put them into `rodbot/plugins/my_plugin/lib/` and use `require_relative` where you need them.

### Create Plugins

You can create plugins in any of the following places:

* inside your Rodbot instance:<br>`/lib/rodbot/plugins/my_plugin`
* in a vendored gem "rodbot-my_plugin":<br>`/lib/rodbot/vendor/gems/rodbot-my_plugin/lib/rodbot/my_plugin`
* in a published gem "rodbot-my_plugin":<br>`/lib/rodbot/plugins/my_plugin`

Please adhere to common naming conventions and use the dashed prefix `rodbot-` (and Module `Rodbot`), however, underscores in case the remaining gem name consists of several words.

#### App Extension

An app extension `rodbot/plugins/my_plugin/app.rb` looks something like this:

```ruby
module Rodbot
  class Plugins
    module MyPlugin
      module App

        module Routes < Roda
          route do |r|
            # GET /my_plugin
            r.root do
              # called by command !my_plugin
            end

            # GET /my_plugin/whatever
            r.get('whatever') do
              # not reachable by any command
            end
          end
        end

        module ResponseMethods
          # (...)
        end

      end
    end
  end
end
```

The `Routes` module contains all the routes you would like to inject. The above corresponds to `GET /my_plugin/hello`.

The `App` module can be used to [extend all aspects of Roda](https://github.com/jeremyevans/roda#plugins-).

For an example, take a look at the [:hal plugin](https://github.com/svoop/rodbot/tree/main/lib/rodbot/plugins/hal).

#### Relay Extension

A relay extension `rodbot/plugins/my_plugin/relay.rb` looks something like this:

```ruby
module Rodbot
  class Plugins
    module MyPlugin
      class Relay < Rodbot::Relay

        def loops
          SomeAwesomeCommunicationNetwork.connect
          [method(:read_loop), method(:write_loop)]
        end

        private

        def read_loop
          loop do
            # Listen in on the communication network
          end
        end

        def write_loop
          loop do
            # Post something to the communication network
          end
        end

      end
    end
  end
end
```

The `loops` method must returns an array of callables (e.g. a Proc or Method) which will be called when this relay service is started. The loops must trap the `INT` signal.

Proactive messsages require other parts of Rodbot to forward a message directly. To do so, the relay has to implement a TCP socket. This socket must bind to the IP and port you get from the `bind` method which returns an array like `["localhost", 16881]`.

For an example, take a look at the [:matrix plugin](https://github.com/svoop/rodbot/tree/main/lib/rodbot/plugins/matrix).

#### Schedule Extension

A schedule extension `rodbot/plugins/my_plugin/schedule.rb` looks something like this:

```ruby
module Rodbot
  class Plugins
    module MyPlugin
      module Schedule

        # (...)

      end
    end
  end
end
```

Please note: Schedules should just call app service routes and let the app do the heavy lifting.

# TODO: needs further description and examples

For an example, take a look at the [:word_of_the_day plugin](https://github.com/svoop/rodbot/tree/main/lib/rodbot/plugins/word_of_the_day).

## Environment Variables

Variable | Description
---------|------------
RODBOT_ENV | Environment (default: development)
RODBOT_CREDENTIALS_DIR | Override the directory containing encrypted credentials files
RODBOT_SPLIT | Split deploy into individual services when set to "true" (default: false)

## Development

To install the development dependencies and then run the test suite:

```
bundle install
bundle exec rake    # run tests once
bundle exec guard   # run tests whenever files are modified
```

Some tests require Redis and will be skipped by default. You can enable them by setting the following environment variable along the lines of:

```
export RODBOT_SPEC_REDIS_URL=redis://localhost:6379/10
```

You're welcome to join the [discussion forum](https://github.com/svoop/rodbot/discussions) to ask questions or drop feature ideas, [submit issues](https://github.com/svoop/rodbot/issues) you may encounter or contribute code by [forking this project and submitting pull requests](https://docs.github.com/en/get-started/quickstart/fork-a-repo).

