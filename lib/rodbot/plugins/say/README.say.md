# Rodbot Plugin – Say

Write proactive messages to communication networks

## Setup

Activate this plugin in `config/rodbot.rb`:

```ruby
plugin :say
```

Then add `say true` to all relay plugins you'd like to write to:

```ruby
plugin :matrix do
  say true
  (...)
end
```

## Usage

In addition to reactive app routes which are called by a relay, you can now use `say` in proactive app routes which are called e.g. by a schedule:

```ruby
say("Hello, World!")
```

This will write the message "Hello, World!" to all communication networks which have `say true` configured.

You can also focus the message to only one of those networks:

```ruby
say("Hello, Matrix!", on: :matrix)
```
