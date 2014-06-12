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
Sprig::Reap.reap
```

By default, Sprig::Reap will create seed files (currently in `.yaml` only) for every model in your Rails
application.  The seed files will be placed in a folder in `db/seeds` named after the current
`Rails.env`.

If any of the models in your application are using STI, Sprig::Reap will create a single seed file named
after the STI base model.  STI sub-type records will all be written to that file.

### Additional Configuration

Don't like the defaults when reaping Sprig::Reap records? You may specify the target environment
(`db/seeds` target folder), models (`ActiveRecord::Base.subclasses`-only) you want seed files for,
or any ignored attributes you don't want to show up in any of the seed files.

```
# Rake Task
rake db:seed:reap TARGET_ENV=integration MODELS=User,Post IGNORED_ATTRS=created_at,updated_at

# Rails Console
Sprig::Reap.reap(target_env: 'integration', models: [User, Post], ignored_attrs: [:created_at,
:updated_at])
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
