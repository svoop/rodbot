# Rodbot Plugin – GitLab Webhook

Pipeline event announcements from GitLab

## Preparation

The Rodbot app binds to `localhost` by default which cannot be reached from GitLab. Make sure this connection is possible by setting a different IP in `config/rodbot.rb`:

```ruby
app do
  host '0.0.0.0'
end
```

To authenticate the webhook calls from GitLab, create a new random secret token:

```
ruby -r securerandom -e "puts SecureRandom.alphanumeric(20)"
```

## Activation

Activate and configure this plugin in `config/rodbot.rb`:

```ruby
plugin :gitlab_webhook do
  secret_tokens '<TOKEN>'
end
```

You can set any number of secure tokens here separated with colons.

## Add Repositories

Add a webhook to every GitLab repository you'd like to see pipeline event announcements for. Go to `https://gitlab.com/<USER>/<REPO>/-/hooks` and create a new webhook with the following properties:

* URL: `https://<RODBOT-APP>/gitlab_webhook`
* Secret token: `<TOKEN>`
* Trigger: [x] Pipeline events
* SSL verification: [x] Enable SSL verification
