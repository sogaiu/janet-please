(import ../name)

(def cmd-name name/cmd-name)

(def bc-src
  (string/format
    ``
    _%s_subcommands() {
      COMPREPLY=( $(compgen -W "$(%s list-subcommands)" -- ${COMP_WORDS[COMP_CWORD]}) );
    }
    complete -F _%s_subcommands %s
    ``
    cmd-name cmd-name cmd-name cmd-name))

(def config
  {:help (string/format "Print bash completion function.")
   :rules []
   :fn (fn [_meta _args]
         (print bc-src))})

