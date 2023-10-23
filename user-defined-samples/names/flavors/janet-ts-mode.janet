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
  (print (t/format (stringify things) indent indent indent cols))
  (print))

(def indent 15)
(def cols 72)

(defn main
  [& args]
  (dump n/dynamic-variables indent cols "dynamic variables")
  #
  (dump n/variables indent cols "builtin variables")
  #
  (dump n/jpm-callables indent cols "jpm builtin values")
  #
  (dump n/special-forms indent cols "special forms")
  #
  (dump n/macros indent cols "builtin macros")
  (dump n/obsolete-macros indent cols "obsolete builtin macros")
  #
  (dump n/functions indent cols "builtin functions")
  (dump n/debug-functions indent cols "builtin debug functions")
  (dump n/obsolete-functions indent cols "obsolete builtin functions"))

