# helix/runtime/queries/janet-simple/highlights.scm

(import ../names :as n)
(import ../text :as t)

# two backslashes needed to construct string for helix
(def sym-char-escapes
  {"*" `\\*`
   "+" `\\+`
   "-" `\\-`
   "?" `\\?`})

(def char-escapes-set
  (string/join (keys sym-char-escapes) ""))

(comment

  char-escapes-set
  # =>
  "+-?*"
  
  )

(defn escape
  [sym-name]
  (def esc-grammar
    (peg/compile
      ~(accumulate
         (some
           (choice (replace (capture (set ,char-escapes-set))
                            ,(fn [char-str]
                               (get sym-char-escapes char-str)))
                   (capture 1))))))
  (first (peg/match esc-grammar sym-name)))

(comment

  (escape `*=`)
  # =>
  `\\*=`

  (escape `++`)
  # =>
  `\\+\\+`

  (escape `if-let`)
  # =>
  `if\\-let`

  (escape `any?`)
  # =>
  `any\\?`

  (escape `-?>`)
  # =>
  `\\-\\?>`

  )

(defn stringify
  [things]
  (-> (map escape things)
      (string/join "|")))

(comment

  (stringify [`*=` `all-bindings` `nil?` `+=`])
  # =>
  `\\*=|all\\-bindings|nil\\?|\\+=`

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
  (dump n/functions indent cols "builtin functions")
  #
  (dump n/variables indent cols "builtin variables")
  (dump n/debug-functions indent cols "builtin debug functions")
  (dump n/obsolete-functions indent cols "obsolete builtin functions"))

