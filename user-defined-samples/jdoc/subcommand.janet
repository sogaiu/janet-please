(import jplz/debug)

(def deprintf debug/deprintf)

########################################################################

(defn escape
  [name]
  # XXX: doing multiple linear searches seems bad
  (cond
    (string/find "*" name)
    (string "\"" name "\"")
    #
    (string/find "<" name)
    (string "\"" name "\"")
    #
    (string/find ">" name)
    (string "\"" name "\"")
    # XXX: any other characters to be careful of?
    name))

########################################################################

# XXX: work-around for redundancy...
(def about-string
  "Show docstring for Janet thing.")

(def config
  {:help about-string # used for most general usage message
   :rules [:thing {:help "Janet thing to get docstring for."}
           "--raw-all" {:help "Show all supported Janet things."
                        :kind :flag}]
   :info {:about about-string} # used when subcommand has --help option
   :fn (fn [_meta args]
         (when (get-in args [:opts "raw-all"])
           (each binding (all-bindings)
             (print (escape binding)))
           (os/exit 0))
         #
         (def thing
           (get-in args [:params :thing]))
         (deprintf "%p" thing)
         (def doc-arg
           (if thing
             (if ((curenv) (symbol thing))
               thing
               (string `"` thing `"`))
             (let [all (all-bindings)
                   idx (math/rng-int (math/rng (os/cryptorand 3))
                                     (length all))]
               (get all idx))))
         (let [code-string (string "(doc " doc-arg ")")]
           (eval-string code-string)))})

