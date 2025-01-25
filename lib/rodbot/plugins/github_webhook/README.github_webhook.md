# Rodbot plugin – GitHub webhook

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

Configure this plugin in `config/rodbot.rb`:

```ruby
plugin :github_webhook do
  secret_tokens '<TOKEN>'
end
```

You can set any number of secure tokens here separated with colons.

## Activation

Add a webhook to every GitHub repository you'd like to see pipeline event announcements for. Go to `https://github.com/<USER>/<REPO>/settings/hooks` and create a new webhook with the following properties:

* Payload URL: `https://<RODBOT-APP>/github_webhook`
* Content type: `application/json`
* Secret: `<TOKEN>`
* SSL verification: (o) Enable SSL verification
* Which events? (o) Let me select individual events: [x] Workflow runs
* And... [x] Active

Use the test tool to verify your setup and to see what the JSON payloads look like in case you'd like to customize the handler.

## Customization

You can change how the plugin reacts to which webhook requests by configuring a custom handler proc. Here's the default one:

```ruby
plugin :github_webhook do
  handler ->(request) do
    if request.env['HTTP_X_GITHUB_EVENT'] == 'workflow_run'
      json = JSON.parse(request.body.read)
      project = json.dig('repository', 'full_name')
      status = json.dig('workflow_run', 'status')
      status = json.dig('workflow_run', 'conclusion') if status == 'completed'
      emoji = case status
        when 'requested' then '🟡'
        when 'success' then '🟢'
        when 'failure' then '🔴'
        else '⚪️'
      end
      [emoji, project, status.gsub('_', ' ')].join(' ')
    end
  end
end
```
