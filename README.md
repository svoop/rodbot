[![Version](https://img.shields.io/gem/v/rodbot.svg?style=flat)](https://rubygems.org/gems/rodbot)
[![Tests](https://img.shields.io/github/actions/workflow/status/svoop/rodbot/test.yml?style=flat&label=tests)](https://github.com/svoop/rodbot/actions?workflow=Test)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/svoop/rodbot.svg?style=flat)](https://codeclimate.com/github/svoop/rodbot/)
[![Donorbox](https://img.shields.io/badge/donate-on_donorbox-yellow.svg)](https://donorbox.org/bitcetera)

<img src="https://github.com/svoop/rodbot/raw/main/doc/rodbot.avif" alt="Rodbot" height="125" align="left">

# Rodbot

Minimalistic yet polyglot framework to build bots on top of a Roda backend.

<br clear="all">

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
