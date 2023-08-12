(import jplz/debug)

(def deprintf debug/deprintf)

########################################################################

# notes:
#
# * depends on structure of files in margaret's examples directory

(import ./random :as rnd)
(import ./show/doc :as doc)
(import ./show/usages :as u)
(import ./show/questions :as qu)
(import ./view :as view)

(def examples-table
  {"+" "choice"
   "*" "sequence"
   "opt" "between"
   "?" "between"
   "!" "not"
   ">" "look"
   "<-" "capture"
   "quote" "capture"
   "/" "replace"
   "$" "position"
   "%" "accumulate"
   "->" "backref"
   #
   "integer" "0.integer"
   "string" "0.string"
   "struct" "0.struct"})

# XXX: brittle because depends on current file's name
(def examples-dir-path
  (do
    (def fname-idx
      (string/find "subcommand.janet" (dyn :current-file)))
    (def dir-path
      (string/slice (dyn :current-file) 0 fname-idx))
    (string dir-path "examples")))

(defn find-example-file-path
  [name]
  (def path (string examples-dir-path "/" name ".janet"))
  (when (os/stat path)
    path))

(defn all-example-file-names
  []
  (when (os/stat examples-dir-path)
    (os/dir examples-dir-path)))

(defn all-names
  [file-names]
  (def names
    (->> file-names
         # drop .janet extension
         (map |(string/slice $ 0
                             (last (string/find-all "." $))))
         # only keep things that have names
         (filter |(not (string/has-prefix? "0." $)))))
  # add things with no names
  (array/push names "integer")
  (array/push names "string")
  (array/push names "struct")
  # add aliases
  (each alias (keys examples-table)
    (let [name (get examples-table alias)]
      (unless (string/has-prefix? "0." name)
        (when (index-of name names)
          (array/push names alias)))))
  #
  names)

(defn choose-random-special
  [file-names]
  (let [all-idx (index-of "0.all-the-names.janet" file-names)]
    (unless all-idx
      (errorf "Unexpected failure to find file with all the names: %M"
              file-names))
    (def file-name
      (rnd/choose (array/remove file-names all-idx)))
    # return name without extension
    (string/slice file-name 0
                  (last (string/find-all "." file-name)))))

########################################################################

# XXX: work-around for redundancy...
(def about-string
  "View Janet PEG information.")

(def config
  {:help about-string # used for most general usage message
   :rules [:thing {:help "Target Janet PEG special."}
           "--doc" {:kind :flag :short "d"
                    :help "Show doc."}
           "--quiz" {:kind :flag :short "q"
                     :help "Show quiz question."}
           "--usage" {:kind :flag :short "u"
                      :help "Show usages."}
           "--raw-all" {:help "Show all supported Janet PEG specials."
                        :kind :flag}]
   :info {:about about-string # used when subcommand has --help option
          :usages ["Usage: jplz pdoc [--doc] [--quiz] [--usage] [thing]"
                   "       jplz pdoc [--help | --raw-all]"]}
   :fn (fn [_meta args]
         (setdyn :pdoc-rng
                 (math/rng (os/cryptorand 8)))

         (view/configure)

         # help completion by showing a raw list of relevant names
         (when (get-in args [:opts "raw-all"])
           (def file-names
             (try
               (all-example-file-names)
               ([e]
                 (eprint "Problem determining all names.")
                 (eprint e)
                 nil)))
           (unless file-names
             (eprintf "Failed to find all names.")
             (os/exit 1))
           (doc/all-names (all-names file-names))
           (os/exit 0))

         # check if there was a peg special specified
         (var peg-special
           (let [cand (get-in args [:params :thing])]
             (if-let [alias (get examples-table cand)]
               alias
               cand)))

         # if no peg-special found and no options, show info about all specials
         (when (and (nil? peg-special)
                    (nil? (get-in args [:opts "doc"]))
                    (nil? (get-in args [:opts "usage"]))
                    (nil? (get-in args [:opts "quiz"])))
           (if-let [file-path (find-example-file-path "0.all-the-names")]
             (do
               (unless (os/stat file-path)
                 (eprintf "Failed to find file: %s" file-path)
                 (os/exit 1))
               (doc/normal-doc (slurp file-path))
               (os/exit 0))
             (do
               (eprint "Hmm, something is wrong, failed to find all the names.")
               (os/exit 1))))

         # ensure a peg-special beyond this form by choosing one if needed
         (unless peg-special
           (def file-names
             (try
               (all-example-file-names)
               ([e]
                 (eprint "Problem determining all names.")
                 (eprint e)
                 nil)))
           (unless file-names
             (eprintf "Failed to find all names.")
             (os/exit 1))
           (set peg-special
                (choose-random-special file-names)))

         # show docs, usages, and/or quizzes for a peg-special
         (let [file-path (find-example-file-path peg-special)]

           (unless file-path
             (eprintf "Did not find file for `%s`" peg-special)
             (os/exit 1))

           (unless (os/stat file-path)
             (eprintf "Hmm, something is wrong, failed to find file: %s"
                      file-path)
             (os/exit 1))

           # XXX: could check for failure here
           (def content
             (slurp file-path))

           (when (or (and (get-in args [:opts "doc"])
                          (get-in args [:opts "usage"]))
                     (and (nil? (get-in args [:opts "doc"]))
                          (nil? (get-in args [:opts "usage"]))
                          (nil? (get-in args [:opts "quiz"]))))
             (doc/special-doc content)
             ((dyn :pdoc-hl-prin) (string/repeat "#" (dyn :pdoc-width))
                                  (dyn :pdoc-separator-color))
             (print)
             (u/special-usages content)
             (os/exit 0))

           (when (get-in args [:opts "doc"])
             (doc/special-doc content))

           (cond
             (get-in args [:opts "usage"])
             (u/special-usages content)
             #
             (get-in args [:opts "quiz"])
             (qu/special-quiz content))))})

