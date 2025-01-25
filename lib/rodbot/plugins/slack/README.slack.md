# Rodbot plugin – Slack

Relay with the Slack communication network

## Preparation

To get an `access_token`, you have to follow the [basic app setup guide](https://api.slack.com/authentication/basics):

1. [Create a new Slack classic app](https://api.slack.com/apps?new_classic_app=1)
2. In the overlay: Give the app a name and pick the workspace for the app and the bot.
3. In the sidebar: Click on "Basic Information", unfold "Add features and functionality" and hit "Bots". Then click the "Add Legacy Bot User" button and in the overlay enter the display name (used e.g in the user list) and user name (used e.g. for mentions). Optionally activate "Always Show My Bot as Online".
4. In the sidebar: Click on "Basic Information" again, scroll down to "Display Information" to set an app icon, color and descriptions. Click "Save Changes" when done".
5. Scroll up and click the "Install to Workspace" button, then click "Allow".
6. In the sidebar: Click on "Basic Information" again, scroll down to "App Credentials" and copy the "Signing Secret" which will be used as `signing_secret` below.
7. In the sidebar: Click on "OAuth and Permissions" and copy the "Bot User OAuth Token" (starting with "xoxb-") which will be used as `access_token` below.

With the app in place, open the Slack client with your normal user, then:

1. Select the channel you want the bot to be present in.
2. In the upper right corner click on "View all members of this channel".
3. Select the "Integrations" tab, then click on "Add apps" and add the app you've just created.
4. Select the "About" tab, scroll all the way down and note the `channel_id` to be used below.

## Activation

Install the required gems via the corresponding Bundler group:

```
bundle config set --local with slack
bundle install
```

Then activate and configure this plugin in `config/rodbot.rb`:

```ruby
plugin :slack do
  access_token '<TOKEN>'
  channel_id '<CHANNEL_ID>'
end
```

You might want to use the credentials facilities of Rodbot to encrypt the token.

## Usage

Once Rodbot is restarted, the Slack relay starts listening. To check whether the relay works fine, just say +!ping+ in the channel, you should receive a "pong" in reply.

Any room message beginning with "!" is considered a bot command.

To post messages to the primary channel configured with the plugin:

```
Rodbot.say('Hello, world!')
```

It's possible to post to other, secondary channels, provided you have previously added the bot app to those secondary channels as [described above](#preparation):

```
Rodbot.say('Hello, world!', room: '#general')
```

Please note that Rodbot uses the term "room" for what is called a channel on Slack.
