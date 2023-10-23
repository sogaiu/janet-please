(def default-cols 72)

(defn split-words
  ```
  Split a string into words
  ```
  [str]
  (peg/match ~(any (choice " "
                           (cmt (capture (at-least 2 "\n"))
                                ,(fn [_] "\n\n"))
                           "\n"
                           (capture (to (choice " " "\n" -1)))))
             str))

(comment

  (split-words "hello there sam")
  # =>
  @["hello" "there" "sam"]

  (split-words
    ``
    A first paragraph.

    A second paragraph.
    ``)
  # =>
  @["A" "first" "paragraph." 
    "\n\n" 
    "A" "second" "paragraph."]

  (split-words
    ``
    A first paragraph.


    A second paragraph.
    ``)
  # =>
  @["A" "first" "paragraph." 
    "\n\n" 
    "A" "second" "paragraph."]

  )

# XXX: adapted from argy-bargy's indent-str
# XXX: "Hanging Indent" https://www.computerhope.com/jargon/h/hanginde.htm
(defn format
  ```
  Formats a string.

  `start-w` (start width - default 0) specifies the starting tracking
  position - with respect to wrapping - on the first line.

  `start-p` (start position - default 0) spaces are added at the
  beginning of the result.

  `max-w` (maximum width - default `default-cols` [1]) affects
  wrapping.

  `hang-p` (hanging padding - default 0) affects indentation on all
  lines except the first one.

  [1] `max-w`'s default value is can be overriden by the dynamic
  variable `:text/cols`.
  ```
  [str &opt start-w start-p hang-p max-w]
  (default start-w 0)
  (default start-p 0)
  (default hang-p 0)
  (default max-w (dyn :text/cols default-cols))
  (def res (buffer (string/repeat " " start-p)))
  (var curr-w start-w)
  (var first-in-p? true)
  (each word (split-words str)
    (cond
      first-in-p?
      (do
        (buffer/push res word)
        (+= curr-w (length word))
        (set first-in-p? false))
      #
      (= "\n\n" word)
      (do
        (buffer/push res word (string/repeat " " hang-p))
        (set curr-w hang-p)
        (set first-in-p? true))
      #
      (< (+ curr-w 1 (length word)) max-w)
      (do
        (buffer/push res " " word)
        (+= curr-w (+ 1 (length word))))
      #
      (do
        (buffer/push res "\n" (string/repeat " " hang-p) word)
        (set curr-w (+ hang-p (length word))))))
  res)

(comment

  (format
    ``
    With a peg-special, but no options, show docs and usages.
    If any of "integer", "string", or "struct" are specified as the
    "peg-special", show docs and usages about using those as PEG
    constructs.

    With the `-d` or `--doc` option, show docs for specified
    PEG special, or if none specified, for a randomly chosen one.

    With the `-q` or `--quiz` option, show quiz question for
    specified PEG special, or if none specified, for a randonly chosen
    one.
    ``
    2 2 2 40)
  # =>
  ``
    With a peg-special, but no options,
    show docs and usages. If any of
    "integer", "string", or "struct" are
    specified as the "peg-special", show
    docs and usages about using those as
    PEG constructs.

    With the `-d` or `--doc` option, show
    docs for specified PEG special, or if
    none specified, for a randomly chosen
    one.

    With the `-q` or `--quiz` option,
    show quiz question for specified PEG
    special, or if none specified, for a
    randonly chosen one.
  ``

  )
