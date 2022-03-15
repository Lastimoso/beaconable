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
- destroyed_entry? :  Returns true if the item has been destroyed

You can also used the following chained methods
- field_change(:field_name).from('first_alternative', 'n_alternative').to('first_alternative_for_to', 'second_alternative_for_to', 'n_alternative_for_toq')

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

### Avoid firing a beacon

You can skip beacon calls if you pass true to the method `#skip_beacon`. I.E:
```
...
 user.update(user_params)
 user.skip_beacon = true
 user.save # The user beacon won't be fired.
```

### Beacon metadata

You can pass `beacon_metadata` to the `object` that will be available on the **Beacon**.

Some uses might be:

- to determine whether a certain action should be performed or not. For example when creating users in batch actions or in through the console you might want to skip just the welcome email but still perform all the other side effects associated with the user creation.
- to pass information that is generated / available in memory, will not be persisted in the model but is relevant in the side effects. For example, if you want to implement your own event logging system you could pass the current user id from the controller action to the beacon where you are going to create the Event.

```ruby
User.create(
  email: "new_user@email.com",
  beacon_metadata: {
    skip_welcome_user_job: true,
    triggered_by: "admin@myapp.com"
  }
)

# app/beacons/user_beacon.rb
class UserBeacon < Beaconable::BaseBeacon
  alias user object
  alias user_was object_was

  def call
    WelcomeUserJob.perform_later(self.id) if should_perform_welcome_user_job?
    UpdateExternalServiceJob.perform_later(self.id) if field_changed? :email
    Event.create do |event|
      event.content = UserSerializer.new(user).event_content
      event.ocurred_at = user.updated_at
      if beacon_metadata.present?
        event.triggered_by = beacon_metadata.dig(:triggered_by)
        event.source = beacon_metadata.dig(:source)
      end
    end
  end

  private

  def should_perform_welcome_user_job?
    new_entry? && !skip_welcome_user_job?
  end

  def skip_welcome_user_job?
    beacon_metadata[:skip_welcome_user_job] if beacon_metadata.present?
  end
end
```

**Important**: once the beacon has been _fired_ the `beacon_metadata` will be cleared.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/beaconable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Beaconable project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/beaconable/blob/master/CODE_OF_CONDUCT.md).
