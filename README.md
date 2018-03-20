# Formally

A slim wrapper around `dry-validations` that makes it easier to write stateful form objects

## Usage

Add a schema to your class

```
class UserUpdateForm
  prepend Formally
  formally do |f|
    required(:name)     { str? }
    required(:password) { eql? f.user.password }
  end

  attr_reader :user

  def initialize user
    @user = user
  end

  # This method will only ever be called with data validated by the
  # schema above
  def fill data
    @user.name = data.fetch(:name)
  end

  # This method is wrapped in a (configurable) transaction
  def save
    # ...
  end
end
```

and use it

```
form = UserUpdateForm.new(user: ...)
form.fill(name: 'James Dabbs', password: 'hunter2').save!
```

## API

Note that `Formally` does _prepend_ and so alters the following methods:

* fill(data) - only ever called with valid data; always returns the form
* save - wrapped in a transaction; returns true or false
* save! - calls `save` or raises an error

It also adds

* formally - contains most form metadata
* errors - to retrieve errors after `fill`ing
* valid? - to check if the form was `fill`ed with valid data

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jamesdabbs/formally. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

