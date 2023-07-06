# Rodbot Plugin – Matrix

Relay with the Matrix communication network

## Preparation

To get an `access_token`, you have to create a new bot user. (Actually, Matrix does not know special bot users, just create a normal one instead.)

1. Create a regular Matrix user account with [Element](https://app.element.io)
2. In "All settings", set the display name, upload a user picture and disable all notifications. If the bot is supposed to join encrypted rooms as well, you should download the backup keys.
3. You find the access token in "All settings -> Help & About".

Invite this new bot user to the room of your choice and figure out the corresponding `room_id`. You can use the public room ID (e.g. `#myroom:matrix.org`) but since it may change you're better off using the internal room ID (e.g. `!kg7FkT64kGUgfk8R7a:matrix.org`) instead:

1. Right click on the room in question and select "Settings"
2. Click on "Advanced"

## Activation

Install the required gems via the corresponding Bundler group:

```
bundle config set --local with matrix
bundle install
```

Then activate and configure this plugin in `config/rodbot.rb`:

```ruby
plugin :matrix do
  access_token: '<TOKEN>'
  room_id: '<ID>'
end
```

You might want to use the credentials facilities of Rodbot to encrypt the token.

## Usage

Once Rodbot is restarted, the Matrix relay will automatically accept the invitation and start listening. To check whether the relay works fine, just say +!ping+ in the room, you should receive a "pong" in reply.

Any room message beginning with "!" is considered a bot command.
