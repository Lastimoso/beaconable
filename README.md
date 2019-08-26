# Beaconable

[![Build Status](https://travis-ci.org/Lastimoso/beaconable.svg?branch=master)](https://travis-ci.org/Lastimoso/beaconable) [![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/dwyl/esta/issues)

Small OO patern to isolate side-effects and callbacks for your ActiveRecord Models.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'beaconable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install beaconable

## Usage
When you include Beaconable in your model it will fire your Beacon everytime after you create or save an entry. Inside your Beacon you have access to the following:

- object (and an alias with the name of your model, i.e user): the instance of your object after changes.
- object_was (and an alias with the name of your model, i.e. user_was): the instance of your object as it was before your changes
- field_changed?(:field_name) : It allows you to check if a specific field was modified.
- any_field_changed?(:field_name, :other_field_name) : It allows you to check if any of multiple fields was modified.
- new_entry? : Returns true if the item saved is new 

### Rails Generator
You can use the bundled generator if you are using the library inside of
a Rails project:

    rails g beacon User

This will do the following:
1. Create a new beacon file in `app/beacons/user_beacon.rb`
2. Will add "include Beaconable" in your User Model.


### Beacon Definition

```ruby
class UserBeacon < Beaconable::BaseBeacon
  alias user object 
  alias user_was object_was
  
  def call
    WelcomeUserJob.perform_later(self.id) if new_entry?
    UpdateExternalServiceJob.perform_later(self.id) if field_changed? :email
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/beaconable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Beaconable project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/beaconable/blob/master/CODE_OF_CONDUCT.md).
