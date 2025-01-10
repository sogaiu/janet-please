(import jplz/debug)

(def deprintf debug/deprintf)

########################################################################

# jlox -> "janet-lang.org examples"

# see janet-lang.org's content/api/gen-docs.janet

(def- replacer
  (peg/compile
    ~(accumulate
       (any
         (choice (replace (capture (set "%*/:<>?"))
                          ,|(string "_" (get $ 0)))
                 (capture 1))))))

(defn- sym-to-filename
  ``
  Convert a symbol to a filename. Certain filenames are not allowed on
  various operating systems.
  ``
  [fname]
  (string "examples/"
          (get (peg/match replacer fname) 0) ".janet"))

########################################################################

(def config
  {:help "Print janet-lang.org examples filename for symbol."
   :rules [:symbol-name {:help "Symbol name"
                         :req? true}]
   :fn (fn [_meta args]
         (def symbol-name
           (get-in args [:params :symbol-name]))
         (deprintf "%p" symbol-name)
         (print (string/slice (sym-to-filename symbol-name)
                              (length "examples/"))))})

