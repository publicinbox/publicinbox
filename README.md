PublicInbox
===========

The NSA can already read your e-mail. Why not let everybody else?

Getting Started
---------------

### Database (PostgreSQL)

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

### Gems (Bundler)

Installing the required gems should be easy as pie:

    bundle install

Note that I've sort of aggressively set the Ruby version at 2.1.1 in the Gemfile. If you want to use an older version, chances are pretty good you can. If you want to have multiple Ruby versions on your computer, might I recommend [RVM](http://rvm.io/)?
