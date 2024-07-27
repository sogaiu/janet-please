# nvim-treesitter/queries/janet_simple/highlights.scm

(import ../names :as n)
(import ../text :as t)

(defn stringify
  [things]
  (-> (map |(string/format `"%s"` $)
           things)
      (string/join " ")))

(comment

  (stringify [`*=` `all-bindings` `nil?` `+=`])
  # =>
  `"*=" "all-bindings" "nil?" "+="`

  )

(defn dump
  [things &opt indent cols header]
  (when header
    (print ";; " header))
  (def groups (t/group-nicely things))
  (each group-name (sort (keys groups))
    (print (t/format (stringify (get groups group-name))
                     indent indent indent cols)))
  (print))

(def indent 4)
(def cols 72)

(defn main
  [& args]
  (dump n/special-forms indent cols "special forms")
  #
  (dump n/macros indent cols "builtin macros")
  (dump n/obsolete-macros indent cols "obsolete builtin macros")
  #
  (dump n/functions indent cols "builtin functions")
  (dump n/debug-functions indent cols "builtin debug functions")
  (dump n/obsolete-functions indent cols "obsolete builtin functions")
  #
  (print "Consider checking contribution guidelines and the content")
  (print "of the last successful PR as nvim-treesitter may have")
  (print "a specific formatter they want used.")
  (print)
  (print "https://github.com/nvim-treesitter/nvim-treesitter/pull/6789"))


