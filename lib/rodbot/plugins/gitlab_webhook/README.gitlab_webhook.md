# Rodbot plugin – GitLab webhook

Pipeline event announcements from self-hosted [GitLab](https://gitlab.com/gitlab-org/gitlab) or managed services like [gitlab.com](https://gitlab.com)

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

Configure this plugin in `config/rodbot.rb`:

```ruby
plugin :gitlab_webhook do
  secret_tokens '<TOKEN>'
end
```

You can set any number of secure tokens here separated with colons.

## Activation

Set up a webhook to every GitLab repository you'd like to see pipeline event announcements for. Go to `https://gitlab.com/<USER>/<REPO>/-/hooks` and create a new webhook with the following properties:

* URL: `https://<RODBOT-APP>/gitlab_webhook`
* Secret token: `<TOKEN>`
* Trigger: [x] Pipeline events
* SSL verification: [x] Enable SSL verification

Use the test tool to verify your setup and to see what the JSON payloads look like in case you'd like to customize the handler.

## Customization

You can change how the plugin reacts to which webhook requests by configuring a custom handler proc. Here's the default one:

```ruby
plugin :gitlab_webhook do
  handler ->(request) do
    json = JSON.parse(request.body.read)
    if json['object_kind'] == 'pipeline'
      project = json.dig('project', 'path_with_namespace')
      status = json.dig('object_attributes', 'detailed_status')
      emoji = case status
        when 'running' then '🟡'
        when 'passed' then '🟢'
        when 'failed' then '🔴'
        else '⚪️'
      end
      [emoji, project, status.gsub('_', ' ')].join(' ')
    end
  end
end
```
