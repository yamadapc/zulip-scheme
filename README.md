# zulip-scheme

A quasi-complete Zulip API wrapper written in Chicken Scheme. Just for the Lulz.
Only the functions for sending messages are wrapped.

## Example
```lisp
(define my-conn (simple-conn "scheme-bot@students.hackerschool.com"
                             "scheme-bot-key"))

(zulip-private-message my-conn
                       "Hey there, I'm written in Scheme... Hahahaha"
                       '("some-cool-user@google.com"))
```

## License
This code is licensed under the MIT license for Pedro Tacla Yamada. Please refer
to the [LICENSE](/LICENSE) file for more information.
