(import jplz/debug)

(def deprintf debug/deprintf)

########################################################################

# XXX: ignores level 1 headers
# XXX: doesn't work for headers with links
# XXX: only works with ascii
# XXX: only works with #-style headers

(defn massage
  [descr]
  (peg/match ~(accumulate
                (some (choice # keep ascii, but lowercase it
                              (replace (capture :a+)
                                       ,string/ascii-lower)
                              # compress each non-ascii sequence to minus
                              (replace (capture (to (choice :a -1)))
                                       "-"))))
             descr))

(comment

  (massage "Notes")
  # =>
  @["notes"]

  (massage "Filesystem and Terminal")
  # =>
  @["filesystem-and-terminal"]

  (massage "Source Analysis, Generation, and Manipulation")
  # =>
  @["source-analysis-generation-and-manipulation"]

  (massage "`bash`")
  # =>
  @["-bash-"]

  )

(defn make-target
  [descr]
  (string/trim (first (massage descr))
               "-"))

(comment

  (make-target "Notes")
  # =>
  "notes"

  (make-target "Filesystem and Terminal")
  # =>
  "filesystem-and-terminal"

  (make-target "Source Analysis, Generation, and Manipulation")
  # =>
  "source-analysis-generation-and-manipulation"

  (make-target "`bash`")
  # =>
  "bash"

  )

(defn toc
  [content]
  (def results
    (peg/match ~{:main (some (choice :header-line
                                     :other-line))
                 # header-line captures as a 2-element array
                 #
                 # example:
                 #
                 #   ## A Description!
                 #
                 # gets captured as:
                 #
                 #   @[2 "A Description!"]
                 :header-line (group
                                # N.B. ignores level 1 headers
                                (sequence (cmt (capture (at-least 2 "#"))
                                               ,|(length $0))
                                          :s+
                                          (capture (to (choice "\n" -1)))
                                          :line-end))
                 :line-end (choice "\n" -1)
                 :other-line (thru :line-end)}
               content))
  (each [hdr-lvl descr] results
    (printf "%s* [%s](#%s)"
            (string/repeat "  " (- hdr-lvl 2))
            descr
            (make-target descr))))

########################################################################

(def config
  {:help "Generate TOC for a Markdown file."
   :rules [:file-path {:help "Input file"
                       :req? true}]
   :fn (fn [_meta args]
         (def file-path
           (get-in args [:params :file-path]))
         (deprintf "%p" file-path)
         (def stat (os/stat file-path))
         # only operate on ordinary files
         (when (= :file (get stat :mode))
           (print (toc (slurp file-path)))))})

