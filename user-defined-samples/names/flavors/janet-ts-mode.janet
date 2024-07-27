# janet-ts-mode/janet-ts-mode.el

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
    #(print (string/repeat " " indent) ";; " header))
    (print ";; " header))
  (def groups (t/group-nicely things))
  (each group-name (sort (keys groups))
    (print (t/format (stringify (get groups group-name)) 
                     indent indent indent cols)))
  (print))

(def cols 72)

(defn main
  [& args]
  (dump n/dynamic-variables 15 cols "dynamic variables")
  #
  (dump n/variables 15 cols "builtin variables")
  #
  (dump n/jpm-callables 15 cols "jpm builtin values")
  #
  (dump n/special-forms 15 cols "special forms")
  #
  (dump n/macros 8 cols "builtin macros")
  (dump n/obsolete-macros 8 cols "obsolete builtin macros")
  #
  (dump n/functions 8 cols "builtin functions")
  (dump n/debug-functions 8 cols "builtin debug functions")
  (dump n/obsolete-functions 8 cols "obsolete builtin functions"))

