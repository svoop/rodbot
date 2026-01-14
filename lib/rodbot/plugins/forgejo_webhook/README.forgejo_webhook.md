# Rodbot plugin – Forgejo webhook

Pipeline event announcements from self-hosted [Forgejo](https://forgejo.org) or managed services like [Codeberg](https://codeberg.org)

## Preparation

The Rodbot app binds to `localhost` by default which cannot be reached from Forgejo. Make sure this connection is possible by setting a different IP in `config/rodbot.rb`:

```ruby
app do
  host '0.0.0.0'
end
```

To authenticate the webhook calls from Forgejo, create a new random secret token:

```
ruby -r securerandom -e "puts SecureRandom.alphanumeric(20)"
```

Configure this plugin in `config/rodbot.rb`:

```ruby
plugin :forgejo_webhook do
  secret_tokens '<TOKEN>'
end
```

You can set any number of secure tokens here separated with colons.

## Activation

Add a webhook to every Forgejo repository you'd like to see pipeline event announcements for. Go to `https://codeberg.org/<USER>/<REPO>/settings/hooks/forgejo/new" and create a new webhook with the following properties:

* Target URL: `https://<RODBOT-APP>/forgejo_webhook`
* HTTP method: `POST`
* POST content type: `application/json`
* Secret: `<TOKEN>`
* Trigger on: (o) Custom events...
  * [x] Failure
  * [x] Success
* Branch filter: `*`
* Authorization header: *empty*
* [x] Active

Use the test tool to verify your setup and to see what the JSON payloads look like in case you'd like to customize the handler.

## Customization

You can change how the plugin reacts to which webhook requests by configuring a custom handler proc. Here's the default one:

```ruby
plugin :forgejo_webhook do
  handler ->(request) do
    json = JSON.parse(request.body.read)
    project = json.dig('run', 'repository', 'full_name')
    status = json.dig('run', 'status')
    emoji = case status
      when 'success' then '🟢'
      when 'failure' then '🔴'
      else '⚪️'
    end
    [emoji, project, status.gsub('_', ' ')].join(' ')
  end
end
```
