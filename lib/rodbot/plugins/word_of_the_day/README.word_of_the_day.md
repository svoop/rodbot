# Rodbot Plugin – Word of the Day

Word of the day announcements

## Setup

Activate and configure this plugin in `config/rodbot.rb`:

```ruby
plugin :word_of_the_day do
  time '10:00'
end
```

By default, the English word of the day from Merriam-Webster is used, but you can [select another language from Transparent](https://www.transparent.com/word-of-the-day/):

```ruby
plugin :word_of_the_day do
  time '10:00'
  languages %w(French)
end
```

You can also select more than one language:

```ruby
plugin :word_of_the_day do
  time '10:00'
  languages %w(English French Swedish)
end
```

Given the above, the word of the day for any given day might look something like this:

```
Word of the day: foobar (English) / foobâr (French) / foobår (Swedish)
```

In case the word of the day is not available, the message will contain the missing language struck through.

