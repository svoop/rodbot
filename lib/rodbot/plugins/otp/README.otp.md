# Rodbot plugin – OTP

Guard commands with one-time passwords

## Preparation

Create a secret key and add it to your authenticator app:

```
require 'rotp'
ROTP::Base32.random
```

## Activation

Activate and configure this plugin in `config/rodbot.rb` using the secret you've created in the previous section:

```ruby
plugin :otp do
  secret '<SECRET>'
  drift 10
end
```

The `drift` config is optional. In this example, one-time passwords are accepted up to 10 seconds beyond their expiration to compensate for slow networks. By default, no drift is granted.

## Usage

To protect a command, just add a guard to the corresponding app route. Say, you have implemented a command `!reboot example.com` in `app/routes/reboot.rb`:

```ruby
module Routes
  class Hello < App

    route do |r|

      # GET /reboot
      r.root do |r|
        response['Content-Type'] = 'text/plain; charset=utf-8'
        ServerService.new(r.arguments).reboot!
        'Done!'
      end

    end

  end
end
```

As a reminder: In the above example, `r.arguments` is a mere shortcut for `r.params['arguments']`.

In order to protect this rather dangerous command with a one-time password, you have to guard the route:

```ruby
r.root do |r|
  r.halt [401, {}, ['Unauthorized']] unless r.valid_otp?
  response['Content-Type'] = 'text/plain; charset=utf-8'
  ServerService.new(r.arguments).reboot!
  'Done!'
end
```

To execute the command now, you have to add the six digit one-time password to the end of it:

```
!reboot example.com 123456
```

The `r.valid_otp?` guard extracts the one-time password from the message and validates it. In this example, a validation result `true` causes the server to be rebooted.

Please note that `r.valid_otp?` redefines `r.arguments` to no longer include the password.

If halting with a 401 error is all you want, there's even a shorter alternative `r.require_valid_otp!`:

```ruby
r.root do |r|
  r.require_valid_otp!
  response['Content-Type'] = 'text/plain; charset=utf-8'
  ServerService.new(r.arguments).reboot!
  'Done!'
end
```

This route does exactly the same as the more verbose one above.

Please note that `r.require_valid_otp!` redefines `r.arguments` to no longer include the password.
