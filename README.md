# Install MongoDB

* Download the [latest MongoDB stable build](http://www.mongodb.org/display/DOCS/Downloads).
* Setup and run Mongo using the [getting started directions](http://www.mongodb.org/display/DOCS/Getting+Started).

# Install Ruby Dependencies

    gem install bundler # unless you are already have it
    bundle

Not familiar with bundler? [Read more about it](http://gembundler.com/).

# Setting up Config Files

* Create a `config/config.yml` using `config/config_example.yml` as an example.
* If using Passenger to run the app (or for deployment), create a `config.ru` using `config.ru.example` as an example.

# Running Test Suite

* Make sure MongoDB is running (see above)
* Run `rake test`
