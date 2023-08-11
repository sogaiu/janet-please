(import ../name)

(def cmd-name name/cmd-name)

(def bc-src
  (string/format
    ``
    _%s_subcommands() {
      local cur=${COMP_WORDS[COMP_CWORD]}
      local prev=${COMP_WORDS[COMP_CWORD - 1]}
      local ls_res=($(%s list-subcommands))
      # XXX: directly using ${ls_res[@]} didn't work...
      local scs=${ls_res[@]}

      if [[ ! " ${ls_res[*]} " =~ " ${prev} " ]]; then
        # XXX: not sure why -- is needed
        COMPREPLY=($(compgen -W "$scs" -- $cur))
      else
        COMPREPLY=($(compgen -df $cur))
      fi
    }
    complete -F _%s_subcommands %s
    ``
    # XXX: yes, this is quite inelegant
    cmd-name cmd-name cmd-name cmd-name))

(def config
  {:help (string/format "Print bash completion function.")
   :rules []
   :fn (fn [_meta _args]
         (print bc-src))})

