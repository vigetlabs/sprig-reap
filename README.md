# Sprig::Reap

[![Code Climate](https://codeclimate.com/github/vigetlabs/sprig-reap.png)](https://codeclimate.com/github/vigetlabs/sprig-reap) [![Build Status](https://travis-ci.org/vigetlabs/sprig-reap.png?branch=master)](https://travis-ci.org/vigetlabs/sprig-reap) [![Gem Version](https://badge.fury.io/rb/sprig-reap.png)](http://badge.fury.io/rb/sprig-reap)

Don't want to write Sprig seed files from scratch?  No problem!  Sprig::Reap can create them for
you.  Sprig::Reap enables automatic capture and output of your application's data state to
Sprig-formatted seed files.

## Installation
```
# Command Line
gem install sprig-reap

# Gemfile
gem 'sprig-reap'
```

## Usage

Via a rake task:
```
rake db:seed:reap
```
Or from the Rails console:
```
Sprig.reap
```

By default, Sprig::Reap will create seed files (currently in `.yaml` only) for every model in your Rails
application.  The seed files will be placed in a folder in `db/seeds` named after the current
`Rails.env`.

If any of the models in your application are using STI, Sprig::Reap will create a single seed file named
after the STI base model.  STI sub-type records will all be written to that file.

### Additional Configuration

Don't like the defaults when reaping Sprig::Reap records? Change 'em!

#### Target Environment
You may specify the target environment (`db/seeds` target folder):
```
# Rake Task
rake db:seed:reap TARGET_ENV=integration

# Rails Console
Sprig.reap(target_env: 'integration')
```

#### Model List
If you only want to `reap` a subset of your models, you may provide a list of models
(`ActiveRecord::Base.subclasses`-only) or `ActiveRecord::Relations` (for pulling records based on
scope):
```
# Rake Task
rake db:seed:reap MODELS=User,Post.published

# Rails Console
Sprig.reap(models: [User, Post.published])
```

#### Ignored Attributes
If there are any ignored attributes you don't want to show up in any of the seed files, let `reap`
know:
```
# Rake Task
rake db:seed:reap IGNORED_ATTRS=created_at,updated_at

# Rails Console
Sprig.reap(ignored_attrs: [:created_at, :updated_at])
```

#### Omitting Empty Attributes
If you have models with lots of attributes that could potentially be `nil`/empty, the resulting seed
files could get cluttered with all the `nil` values.  Remove them from your seed files with:
```
# Rake Task
rake db:seed:reap OMIT_EMPTY_ATTRS=true

# Rails Console
Sprig.reap(omit_empty_attrs: true)
```

#### Combine Them All!
You're free to take or leave as many options as you'd like:
```
# Rake Task
rake db:seed:reap TARGET_ENV=integration MODELS=User,Post.published IGNORED_ATTRS=created_at,updated_at OMIT_EMPTY_ATTRS=true

# Rails Console
Sprig.reap(target_env: 'integration', models: [User, Post.published], ignored_attrs: [:created_at, :updated_at], omit_empty_attrs: true)
```

### Adding to Existing Seed Files (`.yaml` only)

Already have some seed files set up?  No worries!  Sprig::Reap will detect existing seed files and append
to them with the records from your database with no extra work needed.  Sprig::Reap will automatically
assign unique `sprig_ids` so you won't have to deal with pesky duplicates.

NOTE: Sprig::Reap does not account for your application or database validations.  If you reap seed files
from your database multiple times in a row without deleting the previous seed files or sprig
records, you'll end up with duplicate sprig records (but they'll all have unique `sprig_ids`).  This
may cause validation issues when you seed your database.

## License

This project rocks and uses MIT-LICENSE.
