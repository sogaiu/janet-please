# rouge/lib/rouge/lexers/janet.rb

(import ../names :as n)
(import ../text :as t)

(defn stringify
  [things]
  (-> (map |(string/format `%s` $)
           things)
      (string/join " ")))

(comment

  (stringify [`*=` `all-bindings` `nil?` `+=`])
  # =>
  "*= all-bindings nil? +="

  )

(defn dump
  [things &opt indent cols header]
  (when header
    #(print (string/repeat " " indent) "# " header))
    (print "# " header))
  (def groups (t/group-nicely things))
  (each group-name (sort (keys groups))
    (print (t/format (stringify (get groups group-name)) 
                     indent indent indent cols)))
  (print))

(def indent 15)
(def cols 72)

(defn main
  [& args]
  (dump n/special-forms indent cols "special forms")
  #
  (dump n/variables indent cols "builtin variables")
  (dump n/macros indent cols "builtin macros")
  (dump n/obsolete-macros indent cols "obsolete builtin macros")
  (dump n/functions indent cols "builtin functions")
  (dump n/obsolete-functions indent cols "obsolete builtin functions"))

