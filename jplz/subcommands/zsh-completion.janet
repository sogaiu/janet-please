(import ../name)

(def cmd-name name/cmd-name)

(def zc-src
  (string/format
    ``
    _%s_subcommands() {
        local matches=(`%s list-subcommands`)
        compadd -a matches
    }
    compdef _%s_subcommands %s
    ``
    cmd-name cmd-name cmd-name cmd-name))

(def config
  {:help (string/format "Print zsh completion function.")
   :rules []
   :fn (fn [_meta _args]
         (print zc-src))})

