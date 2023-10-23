(import jplz/debug)

(def deprintf debug/deprintf)

########################################################################

(def subcommand-dir
  (do
    (def fname-idx
      (string/find "subcommand.janet" (dyn :current-file)))
    (string/slice (dyn :current-file) 0 fname-idx)))

(def flavors-dir-path
  (string subcommand-dir "flavors"))

(def flavors
  (sort
    (seq [fname :in (os/dir flavors-dir-path)]
      (string/slice fname 0
                    (dec (- (length ".janet")))))))

########################################################################

# XXX: work-around for redundancy...
(def about-string
  "Dump Janet names.")

(def config
  {:help about-string # used for most general usage message
   :rules [:flavor {:help "Flavor of names output."}
           "--list" {:kind :flag :short "l"
                    :help "Show flavors."}]
   :info {:about about-string # used when subcommand has --help option
          :usages ["Usage: jplz names [flavor]"
                   "       jplz names [--help] [--list]"]}
   :fn (fn [_meta args]
         (when (get-in args [:opts "list"])
           (each flavor flavors
             (print flavor))
           (os/exit 0))

         (def cand
           (get-in args [:params :flavor]))

         (when (or (not cand)
                   (empty? cand))
           (eprint "Please invoke jplz name --help for usage.")
           (os/exit 1))

         (def matches
           (seq [flavor :in flavors
                 :when (zero? (string/find cand flavor))]
             flavor))

         (def n-matches (length matches))
         (cond
           (> n-matches 1)
           (do
             (eprint "matched multiple flavors: %n" matches)
             (os/exit 1))
           #
           (zero? n-matches)
           (do
             (eprintf "no flavor matched from: %n" flavors)
             (os/exit 1))
           #
           (do
             (os/cd subcommand-dir)
             (os/execute ["janet"
                          (string flavors-dir-path "/"
                                  (get matches 0) ".janet")]
                         :px))))})

