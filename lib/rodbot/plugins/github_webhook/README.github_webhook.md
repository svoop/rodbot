# Rodbot Plugin – GitHub Webhook

Pipeline event announcements from GitHub

## Preparation

The Rodbot app binds to `localhost` by default which cannot be reached from GitHub. Make sure this connection is possible by setting a different IP in `config/rodbot.rb`:

```ruby
app do
  host '0.0.0.0'
end
```

To authenticate the webhook calls from GitHub, create a new random secret token:

```
ruby -r securerandom -e "puts SecureRandom.alphanumeric(20)"
```

## Activation

Activate and configure this plugin in `config/rodbot.rb`:

```ruby
plugin :github_webhook do
  secret_tokens '<TOKEN>'
end
```

You can set any number of secure tokens here separated with colons.

## Add Repositories

Add a webhook to every GitHub repository you'd like to see pipeline event announcements for. Go to `https://github.com/<USER>/<REPO>/settings/hooks` and create a new webhook with the following properties:

* Payload URL: `https://<RODBOT-APP>/github_webhook`
* Content type: `application/json`
* Secret: `<TOKEN>`
* SSL verification: (o) Enable SSL verification
* Which events? (o) Let me select individual events: [x] Workflow runs
* And... [x] Active
