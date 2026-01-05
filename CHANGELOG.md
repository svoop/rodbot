## Main

### Changes
* Update Ruby to 4.0

## 0.6.0

### Changes
* Drop certs note in README
* Add action for trusted release

## 0.5.2

### Fixes
* Update Docker template for Ruby 3.4.2

## 0.5.1

### Changes
* Update Docker compose templates

## 0.5.0

### Changes
* Make GitLab and GitHub plugins customizable

## 0.4.5

### Changes
* Update Ruby to 3.4

## 0.4.4

### Changes
* Adhere to plugin file layout suggestions
* Support Ruby 3.3
* Honor `APP_ENV` as an alternative to `RODBOT_ENV`

## 0.4.3

### Changes
* Add more languages to the word of the day demo plugin

## 0.4.2

### Fixes
* Pass the time zone down to Clockwork

## 0.4.1

### Fixes
* Fix init of memoization cache

## 0.4.0

### Breaking changes
* Rename `timezone` config to `time_zone` and properly implement and document
  time zone handling

## 0.3.4

### Additions
* Support to post to secondary rooms with `Rodbot.say`
* `Rodbot::Message` container class for messages with meta data

## 0.3.3

### Additions
* Support placeholders when using `Rodbot.say` and add `[[EVERYBODY]]`
  placeholder to mention all hands in a room or channel

## 0.3.2

### Additions
* Simple /healthz route e.g. for deployments on render.com
* Deploy templates for render.com

### Changes
* Switch from httparty to httpx

## 0.3.1

### Fixes
* Explicitly require Forwardable

## 0.3.0

### Additions
* Built-in plugin for Slack

## 0.2.0

### Fixes
* Fix OTP verification
* Drop futile files from packaged gem

## 0.1.1

### Fixes
* Fix `rodbot new` by making `config/rodbot.rb` optional

## 0.1.0

### Initial implementation
* Rodbot CLI
* App, relay and schedule services
* Framework functionality such as config, credentials, logging, data
  persistence, async jobs and so forth
* Refinements and memoization
* Built-in plugins for Matrix, GitHub, GitLab, OTP and some demos
* Require at least Ruby 3.0
