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
* [API](https://www.rubydoc.info/gems/rodbot)
* Author: [Sven Schwyn - Bitcetera](https://bitcetera.com)

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
bundle install
bundle exec rodbot --help
```

## Anatomy

The bot consists of three kinds of services interacting with one another:

```
RODBOT                                                            EXTERNAL
╭╴ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ╶╮
╷ ╭──────────────────╮  <─────>  ╭──────────────────╮       ╷
╷ │ WEB              │  <───╮    │ ADAPTER - Matrix ├╮  <──────>  [1] Matrix
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

### Web Service

The **web service** is a [Roda app](https://roda.jeremyevans.net) where the real action happens. It acts on and responds to HTTP requests from:

* commands forwarded by **adapter services**
* timed events triggered by the **schedule service**
* third party webhook calls e.g. from GitLab, GitHub etc

### Adapter Services

The `bin/` directory contains several **adapter services**. These daemons act as glue between the **web service** and external communication networks such as Matrix. Currently, the following are adapters are available:

* `simulator`<br>CLI simulator for testing only. It presents a prompt which simulates a chat network.
* `matrix`<br>Connects to the given room on the [Matrix network](https://matrix.org) and waits for the bot user to be invited to the room. After the invitation has been accepted automatically, the bot begins to read all messages posted to the room and respond those which contain a command beginning with `!`.

Each adapter does two things:

* It detects commands, forwards them to the **web service** and forwards the HTTP response as a message to the communication network.
* It creates and listens to a local TCP socket. Plain text or Markdown/GFM sent to this socket is forwarded as a message to the corresponding communication network. This text may have multiple lines, use the EOT character (`\x04` alias Ctrl-D) to mark the end.

### Schedule Service

The **schedule service** is a [Clockwork process](https://github.com/Rykian/clockwork) which triggers HTTP requests to the **web service** based on timed events.

## External

### Matrix

Matrix does not feature special bot users, just create a regular one instead:

1. Got to https://app.element.io
2. Create a regular user account and log in
3. In "All settings", set the display name, upload a user picture and disable all notifications. If the bot is supposed to join encrypted rooms as well, you should download the backup keys.
4. You find the access token in "All settings -> Help & About".

#### Usage

Room messages beginning with `!` are considered a bot command.

* The only built-in command is `!ping` which will trigger a simple "pong" response to check whether the **adapter service** is actually listening.
* All other commands such as `!pay EUR 123` trigger a `GET /bot/pay?argument=EUR+123` request to the **web service**.

The response has to be plain text or Markdown/GFM understood by Matrix. Furthermore, the following special tags are recognized and replaced:

* `<SENDER>` – Mention the sender of the command.

### GitLab

For the bot to announce GitLab CI events in the room, you have to [define a webhook](https://docs.gitlab.com/ee/user/project/integrations/webhooks.html) on the corresponding GitLab repository as follows:

* URL: https://halluzinelle.bitcetera.com/gitlab/webhook
* Secret token: One of the secret tokens listed in `BOT_GITLAB_SECRET_TOKENS` (see configuration section above)
* Trigger: Pipeline events
* Enable SSL verification

### GitHub

For the bot to announce GitHub CI events in the room, you have to [define a webhook](https://docs.github.com/en/developers/webhooks-and-events/webhooks/about-webhooks) on the corresponding GitHub repository as follows:

* URL: https://halluzinelle.bitcetera.com/github/webhook
* Content type: application/json
* Secret: One of the secret tokens listed in `BOT_GITHUB_SECRET_TOKENS` (see configuration section above)
* SSL verification: Enable SSL verification
* Let me select individual events: Workflow runs
