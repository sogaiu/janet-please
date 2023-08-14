(import jplz/debug)

(def deprintf debug/deprintf)

########################################################################

(defn count-max-line-length
  [f]
  (var max-length 0)
  (def buf @"")
  (while (file/read f :line buf)
    (def len
      (if (string/has-suffix? "\n" buf)
        (dec (length buf))
        (length buf)))
    (when (> len max-length)
      (set max-length len))
    (buffer/clear buf))
  max-length)

(defn count-newlines
  [f]
  (var num-nls 0)
  (def buf @"")
  (while (file/read f :line buf)
    (when (string/has-suffix? "\n" buf)
      (++ num-nls))
    (buffer/clear buf))
  num-nls)

########################################################################

# XXX: work-around for redundancy...
(def about-string
  "Count various things.")

(def config
  {:help about-string
   :rules [:file-path {:help "Target file"
                       :req? true}
           "--lines" {:help "Print number of newlines."
                      :kind :flag
                      :short "l"}
           "--max-line-length" {:help "Print maximum line length."
                                :kind :flag
                                :short "L"}]
   :info {:about about-string
          :usages ["Usage: jplz count [--lines] file-path"
                   "       jplz count --max-line-length file-path"]}
   :fn (fn [_meta args]
         (def file-path
           (get-in args [:params :file-path]))
         (deprintf "%p" file-path)
         (def stat (os/stat file-path))
         (unless stat
           (eprintf "%s: No such file or directory" file-path)
           (os/exit 1))
         (def mode (get stat :mode))
         (cond
           (= :file mode)
           (with [f (file/open file-path)]
             (cond
               (get-in args [:opts "max-line-length"])
               (print (count-max-line-length f))
               #
               (print (count-newlines f)))
             (os/exit 0))
           #
           (= :directory mode)
           (do
             (eprintf "%s: Is a directory" file-path)
             (os/exit 1))
           #
           (do
             (eprintf "%s: File or directory expected, got: %s"
                      file-path mode)
             (os/exit 1))))})

