(import ./jplz/name)

(def cmd-name name/cmd-name)
(def full-name name/full-name)

(declare-project
  :name full-name
  :url (string/format "https://github.com/sogaiu/%s" full-name)
  :repo (string/format "git+https://github.com/sogaiu/%s.git" full-name))

(declare-binscript
  :main (string/format "bin/%s" cmd-name)
  :is-janet true)

(declare-source
  :source @[cmd-name])

