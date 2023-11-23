[![Version](https://img.shields.io/gem/v/rodbot.svg?style=flat)](https://rubygems.org/gems/rodbot)
[![Tests](https://img.shields.io/github/actions/workflow/status/svoop/rodbot/test.yml?style=flat&label=tests)](https://github.com/svoop/rodbot/actions?workflow=Test)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/svoop/rodbot.svg?style=flat)](https://codeclimate.com/github/svoop/rodbot/)
[![Donorbox](https://img.shields.io/badge/donate-on_donorbox-yellow.svg)](https://donorbox.org/bitcetera)

<img src="https://github.com/svoop/rodbot/raw/main/doc/rodbot.avif" alt="Rodbot" height="125" align="left">

# Rodbot

Minimalistic yet polyglot framework to build chat bots on top of a Roda backend for chatops and fun.

<br clear="all">

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
[Request](#request)<br>
[Say](#say)<br>
[Routes and Commands](#label-Routes-and-Commands) <br>
[Database](#label-Database) <br>
[Environments](#environments) <br>
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

You can use more than one plugin of course. Please note that you have to list them separated with a space:

```
bundle config set --local with matrix slack
bundle install
```

Please refer to the [Matrix plugin README](https://rubydoc.info/github/svoop/rodbot/file/lib/rodbot/plugins/matrix/README.matrix.md) for more on how to configure and authorise this relay service.

Time to add Git to the mix. Both `gems.locked` and `.bundle` are included in order to use the same gems and versions both for local development and deployment to production:

```
git init
git add .
git commit -m "Bootstrap Rodbot"
```

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

See [Rodbot::Config::DEFAULTS](https://github.com/svoop/rodbot/blob/main/lib/rodbot/config.rb) for available config settings and their defaults.

#### Roda

The Roda app is located in the `app` directory. It contains:

* `app.rb` – Roda app class where new routes are added using `run` statements
* `routes\` – Directory which contains one route file for every `run` statement
* `views\` – Directory which contains layouts and views called with `view` in route files

For an example, take a look at `app/routes/help.rb` generated as part of every new Rodbot app.

The `app.rb` loads the Rodbot plugin with `plugin :rodbot`. This Roda plugin is a necessary dependency for many Rodbot plugins and does two things.

It loads the following Roda plugins:

* [multi_run](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/MultiRun.html)
* [environments](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/Environments.html)
* [heartbeat](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/Heartbeat.html)
* [public](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/Public.html)
* [run_append_slash](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/RunAppendSlash.html)
* [halt](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/Halt.html)
* [unescape_path](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/UnescapePath.html)
* [render](http://roda.jeremyevans.net/rdoc/classes/Roda/RodaPlugins/Render.html)

It loads the following Roda extensions provided by Rodbot:

* Shortcut `r.arguments` for `r.params['arguments']`

#### Host

The **app service** binds to `localhost` by default and therefore isolates it from the internet. In case you want to make it publicly reachable, you have to set the `RODBOT_APP_HOST` environment variable to a public IP. Or to bind to all IPs of all interfaces:

```
export RODBOT_APP_HOST=0.0.0.0
```

#### Ports

The **app service** binds to the base port 7200 by default. However, each **relay service** needs a predictable port to bind to as well, which is why the next few following ports must not be in use already. If you have to, you can change the base port in `config/rodbot.rb`:

```ruby
port 12345
```

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
`[[EVERYBODY]]` | Mention everybody.

#### Other Routes

All higher level requests such as `GET /foo/bar` are not accessible by relays. Use them to implement other aspects of your bot such as webhooks or schedule tasks.

### Relay Services

The **relay service** act as glue between the **app service** and external communication networks such as Matrix.

Each relay service does three things:

* **Proactive:** It creates and listens to a local TCP socket which accepts and forwards messages. See below for more on this.
* **Reactive:** It reads messages, detects commands usually beginning with a `!`, forwards them to the **app service** and writes the HTTP response back as a message to the communication network.
* **Test:** It detects the `!ping` command and replies with "pong" *without* hitting the **app service**.

You can simulate such a communication network locally:

```
rodbot simulator
```

Enter the command `!pay EUR 123` and you see the request `GET /pay?argument=EUR+123` hitting the **app service**.

#### TCP Socket

The TCP socket is primarily used by other Rodbot services to forward messages to the corresponding external communication network. However, you can use these sockets for non-Rodbot processes as well e.g. to issue notifications when events happen on the host running Rodbot.

Simply connect to a socket and submit the message as plain text or Markdown in UTF-8. Multiple lines are allowed, to finish and post the message, append the EOT character (`\x04` alias Ctrl-D).

Such simple messages are always posted to the primary room (aka: channel, group etc) of the communication network. For more complex scenarios, please take a look at [message objects](https://www.rubydoc.info/gems/rodbot/Rodbot/Message) which may contain meta information as well.

### Schedule Service

The **schedule service** is a [Clockwork process](https://github.com/Rykian/clockwork) which triggers Ruby code asynchronously as configured in `config/schedule.rb`.

It's a good idea to have the **app service** do the heavy lifting while the schedule simply fires the corresponding HTTP request.

A word or two on time zones since they are particularly important for schedules:

Automatic discovery of the local time zone and DST status is rather unreliable. Therefore, Rodbot expects you to set the time zone in `config/rodbot.rb` using `time_zone`. See `ls /usr/share/zoneinfo` for valid values. To correctly handle DST, you should use geographical zones like `Europe/Paris` rather than technical zones like `CET`. If `time_zone` is not defined, the environment variable `TZ` is read instead. And if `TZ` isn't set neither, Rodbot falls back to `Etc/UTC`.

Also, make sure the [time zone data is available](https://tzinfo.github.io) where you deploy your bot to. The [official Alpine-based Ruby images](https://hub.docker.com/_/ruby) for instance doesn't come with it preinstalled, so you either have to `RUN apk add --no-cache tzdata` in the Dockerfile or add the [tzinfo-data gem](https://rubygems.org/gems/tzinfo-data) to the bundle for `TZ` to have any effect at all.

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

Here's how to start single services in the background:

```
rodbot start app --daemonize
```

You can also start all services at once in which case the services must run in the background and therefore the `--daemonize` is implied and may be omitted:


```
rodbot start
```

Finally, to stop all running Rodbot services:

```
rodbot stop
```

### Deployment

While controlling Rodbot as mentioned in the previous section is okay for local development, deploying the bot to production comes in a gazillion scenarios. Rodbot helps you with scaffolds for some of them. To get the list of all deploy scaffolds:

```
rodbot deploy --help
```

:warning: It's near impossible to include such deployment scenarios in the test suite. If you find an error or have an improvement, please [submit an issue](https://github.com/svoop/rodbot/issues)!

Let's take a quick look at the two most common scenarios:

#### Docker

To run all of Rodbot in one single Docker service:

```
rodbot deploy docker
```

In case you prefer to split each service into its own container:

```
rodbot deploy docker --split
```

The Docker deployment is a `compose.yml` file, so you might want to write it to disk:

```
rodbot deploy docker >compose.yml
```

#### Procfile

The `Procfile` was introduced by Heroku and is nowadays supported many cloud providers as well as tools for local development.

While a monolith approach is certainly possible, it makes more sense to split each service into its own process:

```
rodbot deploy procfile --split
```

As per convention, the `Procfile` should be placed in the root of the project:

```
rodbot deploy procfile --split >Procfile
```

It's easy to test drive using a process manager such as [Foreman](https://rubygems.org/gems/foreman):

```
gem install foreman
foreman start
```

For more control and debug features, you might want to try [Overmind](https://github.com/DarthSim/overmind) instead e.g. installed via [Homebrew](https://brew.sh):

```
brew install overmind
overmind start
```

## Request

To query the **app service**, you can either use the bundled [HTTPX](https://rubygems.org/gems/httpx) gem or the following convenience wrapper:

```ruby
response = Rodbot.request('/time', params: { zone: 'UTC' })
```

This uses the default `method: :get` and the default `timeout: 10` seconds, it returns an instance of [HTTPX::Response](https://www.rubydoc.info/gems/httpx/HTTPX/Response):

```ruby
response.code   # => 200
response.body   # => '2023-09-06 22:51:50.231703 UTC'
```

## Say

You can send proactive messages to communication networks with `Rodbot.say`.

Since you're not limited to just one relay plugin, you have to configure which of them shall post messages submitted with `Rodbot.say` by adding `say true` in `config/rodbot.rb`. Here's an example for the Matrix relay plugin:

```ruby
plugin :matrix do
  say true
  (...)
end
```

With this in place, you can now submit messages from just about anywhere, most notably **app service** routes and **schedule service** jobs.

```ruby
say("Hello, World!")
```

You can further narrow where to post the message if you specify the relay plugin explicitly:

```ruby
say("Hello, Slack!", on: :slack)
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

## Environments

Similar to other frameworks, Rodbot features different environments which affect the way certain processes work. Use the environment variable `RODBOT_ENV` to set control this:

Value | Meaning
------|--------
development | This is the default environment used for local develoment.
production | Use this environment when you deploy Rodbot.
test | This environment is set for the automated tests of Rodbot.

The current environment can be programmatically queried:

```ruby
ENV['RODBOT_ENV'] = "production"
Rodbot.env.current        # => "production"
Rodbot.env.production?    # => true
Rodbot.env.development?   # => false
```

## Credentials

In order not to commit secrets to repositories or environment variables, Rodbot bundles the [dry-credentials](https://rubygems.org/gems/dry-credentials) gem and exposes it via the `rodbot credentials` CLI command. The secrets are then available in your code like `Rodbot.credentials.my_secret` and the encrypted files are written to `config/credentials`.

## Plugins

Rodbot aims to keep its core small and add features via plugins, either built-in or provided by gems.

### Built-In Plugins

Name | Dependencies | Description
-----|--------------|------------
[:matrix](https://rubydoc.info/github/svoop/rodbot/file/lib/rodbot/plugins/matrix/README.matrix.md) | yes | relay service for the [Matrix communication network](https://matrix.org)
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

An app extension `rodbot/plugins/my_plugin/app.rb` defines the module `App` and looks something like this:

```ruby
module Rodbot
  class Plugins
    module MyPlugin
      module App

        module Routes < ::App
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

The `Routes` module contains all the routes you would like to inject.

The `App` module can be used to [extend all aspects of Roda](https://github.com/jeremyevans/roda#plugins-).

For an example, take a look at the [:hal plugin](https://github.com/svoop/rodbot/tree/main/lib/rodbot/plugins/hal).

#### Relay Extension

A relay extension `rodbot/plugins/my_plugin/relay.rb` defines the class `Relay` and looks something like this:

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

Proactive messsages require other parts of Rodbot to forward a message directly. To do so, the relay has to implement a TCP socket. This socket must bind to the IP and port you get from the `bind` method which returns an array like `["localhost", 7201]`.

For an example, take a look at the [:matrix plugin](https://github.com/svoop/rodbot/tree/main/lib/rodbot/plugins/matrix).

#### Schedule Extension

A schedule extension `rodbot/plugins/my_plugin/schedule.rb` defines the class `Schedule` and looks something like this:

```ruby
module Rodbot
  class Plugins
    module MyPlugin
      class Schedule

        def initialize
          Clockwork.every(1.day, -> { tea }, at: '16:00')
        end

        private

        def tea
          Rodbot.say "Time for a cup of tea!"
        end

      end
    end
  end
end
```

The initializer must set at least one schedule using `Clockwork.every` – see the [Clockwork docs](https://www.rubydoc.info/gems/clockwork).

For an example, take a look at the [:word_of_the_day plugin](https://github.com/svoop/rodbot/tree/main/lib/rodbot/plugins/word_of_the_day).

#### Toolbox

Before you write a plugin, familiarize yourself with the following bundled helpers:

* [Rodbot::Refinements](https://www.rubydoc.info/gems/rodbot/Rodbot/Refinements.html) – just a few handy extensions to Ruby core classes
* [Rodbot::Memoize](https://www.rubydoc.info/gems/rodbot/Rodbot/Memoize.html) – environment-aware memoization for method return values

## Environment Variables

Environment variables are used for the configuration bits which cannot or should not be part of `config/rodbot.rb` mainly because they have to be set on the infrastructure level.

Variable | Description | Default
---------|-------------|--------
`RODBOT_ENV` | Environment | development
`RODBOT_CREDENTIALS_DIR` | Override the directory containing encrypted credentials files | config/credentials/
`RODBOT_APP_HOST` | Override where to locally bind the app service | localhost
`RODBOT_APP_URL` | Override where to locally reach the app service | http://localhost
`RODBOT_RELAY_HOST` | Override where to bind the relay services | localhost
`RODBOT_RELAY_URL_XXX` | Override where to locally reach the given relay service `XXX` (e.g. `MATRIX`) | tcp://localhost

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

