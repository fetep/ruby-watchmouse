# ruby-watchmouse

This is a Ruby library to access the [Watchmouse](http://www.watchmouse.com)
[API](http://apidoc.watchmouse.com).

Only API version 1.6 is supported right now (the latest stable version).

## Example library usage

Create a new API object by specifying the version you want, login, and
password:

    require "watchmouse/api"

    api = Watchmouse::API.new("latest", "foo@example.org", "MyPassword")
    api.acct_noop   # Will automatically call acct_login
    api.acct_logout

It's important to call `acct_logout` at the end of your scripts because
the API enforces a maximum number of concurrent sessions.  A session
expires after some period (15 minutes currently) of inactivity.

If you want to preserve the same session across runs, specify a path
to a "cookie jar":

    api = Watchmouse::API.new("latest", "foo@example.org", "MyPassword", "/tmp/cookiejar")

Now that we have an api session, let's inspect all rules with the
tag "foo":

    res = api.rule_get(:tags => "foo")
    res["rules"].each { |rule| puts "got rule #{rule['name']}" }

All methods may raise `Watchmouse::Error` if there is a problem with
the API call.

To see all of the available methods and parameters for those methods,
see the API documentation:

* [1.6 API docs](http://api.watchmouse.com/1.6/)
