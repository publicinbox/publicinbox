PublicInbox
===========

The NSA can already read your e-mail. Why not let everybody else?

Getting Started
---------------

Once your system is set up, run the server locally with Foreman:

    foreman start

For this to work, you'll need to have done the following things (explained below):

1. Set up a PostgreSQL database
2. Install gem dependencies
3. Create a local .env file for environment variables (required for secrets.yml)

### Set up a PostgreSQL database

You'll need PostgreSQL installed, along with the dev package (for the `pg` gem).

#### Ubuntu

Install the database and the development libraries:

    sudo apt-get install postgresql postgresql-contrib libpq-dev

You should probably create a password if you haven't already:

    sudo -u postgres psql postgres
    \password postgres

Now, create the public_inbox user along with dev and test databases:

    sudo -u postgres createuser -D -A -P publicinbox
    sudo -u postgres createdb -O public_inbox public_inbox_development
    sudo -u postgres createdb -O public_inbox public_inbox_test

Finally, create a new database.yml file (I would just `cp database.example.yml database.yml`) and set the password to whatever you just made it.

### Install gem dependencies

Installing the required gems should be easy as pie:

    bundle install

Note that I've sort of aggressively set the Ruby version at 2.1.1 in the Gemfile. If you want to use an older version, chances are pretty good you can. If you want to have multiple Ruby versions on your computer, might I recommend [RVM](http://rvm.io/)?

### Set up environment variables

Foreman uses the .env file to populate environment variables when running `foreman start`. At the very least you need to set the SECRETS_KEY_BASE variable. The simplest way to do this would be to use the `rake secret` task:

    echo "SECRETS_KEY_BASE="`rake secret` >> .env

Optionally, to support logging in through Google, Facebook, and/or Twitter, you can create register development apps for those providers and add the respective keys and secrets to the .env file.
