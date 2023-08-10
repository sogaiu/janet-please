(defn list-subcmds
  []
  [;(dyn :default-subcmds @[]) ;(dyn :user-subcmds @[])])

(def config
  {:help (string/format "List subcommands.")
   :rules []
   :fn (fn [_meta _args]
         (each subcmd (list-subcmds)
           (print subcmd)))})

