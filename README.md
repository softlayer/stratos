# Stratos

Would like to see how SoftLayer API can help on your cloud automating tasks? Are you ready for a demonstration? Fasten your seat belts!

This project is a Ruby on Rails application that offers the possibility to interact to SoftLayer API, exposing a web interface and showing some tasks using your API key, and you give the rules.

## Installation

To run on your machine you need to follow the steps below:

* bundle install (to install Ruby dependencies)
* no need to configure database (we are not persisting any data)
* rails s
* Access http://localhost:3000/
* Login with your API Key

If you'd like to test in a production environment, it's normal rails deployment, set `SECRET_KEY_BASE` variable and run `rake assets:precompile`, that's it!

## Security

Don't worry about logging with your API user and key, because Stratos was develop to avoid data leakage, so we assume some premisses:

* We store your API user and key as a cookie on your browser (vanished when you close your browser)
* Cookies are signed with rails app key and stored in _encrypted_ form, check this [page](http://api.rubyonrails.org/classes/ActionDispatch/Cookies.html) for more info on cookies
* API Key won't be saved on log, as you log, Rails will replace and show `"api_key"=>"[FILTERED]"` on log
* Disabled logging on Jobs that receive api user / key to process API info on background.
* We connect to SoftLayer API using HTTPS

## Roadmap

1. Support creation of Cloud Servers
2. Support creation of Hourly Bare Metal
3. DNS Support
4. Support creation of more complex Bare Metal packages
5. Tickets Interaction
6. Release 0.1

## Technical Premisses

* (Unofficial) SoftLayer Client

[SoftLayer](http://github.com/zertico/softlayer) is a (unofficial) ruby library to talk to SLAPI, it has high level Ruby models, and its the core of this application, if you're a ruby programmer and want to automate some SoftLayer task, we do **really** recommends you to check it!

* Twitter bootstrap

Using twitter bootstrap in the simplest possible way, so it makes easir for you to customize the views.

* Trailblazer

As its own description _Trailblazer is a thin layer on top of Rails. It gently enforces encapsulation, an intuitive code structure and gives you an object-oriented architecture._, so it makes easier to create the integration layer between Rails and SoftLayer API once we don't use ActiveRecord/ActiveModel.

## Contributing

TODO: Write CONTRIBUTING file

## Information

You can get in touch in #softlayer at freenode.

TODO: Should create a google groups or mailing for questions and leave GH just for bugs?

### Questions and Bug reports

If you have any question, please open an issue! If you discover any bugs, feel free to create an issue on GitHub. Please add as much information as possible to help us fixing the possible bug. We also encourage you to help even more by forking and sending us a pull request.

https://github.com/softlayer/stratos/issues

## Maintainers

* Celso Fernandes (https://github.com/fernandes)

## License

[MIT License](LICENSE.md). Copyright (c) 2015 IBM Corporation.
