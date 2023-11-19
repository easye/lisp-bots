(push (directory-namestring *load-truename*)
      asdf:*central-registry*)

(ql:quickload :minion)
(ql:quickload :specbot)
; (asdf:load-system :lisppaste)

(irc-bot:start 'minion:minion)
(irc-bot:start 'specbot:specbot)
