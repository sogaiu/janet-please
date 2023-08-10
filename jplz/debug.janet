(defn deprintf
  [fmt & args]
  (when (os/getenv "VERBOSE")
    (eprintf fmt ;args)))

