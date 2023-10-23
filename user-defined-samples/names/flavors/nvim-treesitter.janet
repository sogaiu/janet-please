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
  (print (stringify things))
  (print))

(def indent 0)
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
  (dump n/obsolete-functions indent cols "obsolete builtin functions"))

