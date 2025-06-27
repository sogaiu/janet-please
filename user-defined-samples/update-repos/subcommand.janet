(import jplz/debug)

(def deprintf debug/deprintf)

########################################################################

(defn path-join
  [& parts]
  (string/join parts
               (dyn :path-fs-sep
                    (if (= :windows (os/which))
                      `\`
                      "/"))))

(defn is-dir?
  [path]
  (when-let [path path
             stat (os/lstat path)]
    (= :directory (stat :mode))))

(defn visit-dirs
  ``
  Recursively traverse directory tree starting at `path`, applying
  argument `a-fn` to each encountered directory path.
  ``
  [path a-fn]
  (when (is-dir? path)
    (each thing (os/dir path)
      (def thing-path
        (path-join path thing))
      (when (is-dir? thing-path)
        (a-fn thing-path)
        (visit-dirs thing-path a-fn)))))

(defn find-repos-roots
  [root &opt dflt-fn]
  (default dflt-fn |true)
  (def repos-roots @{})
  (visit-dirs
    root
    (fn [path]
      (when (string/has-suffix? "/.git" path)
        (def parent-dir
          (string/slice path 0 (- (inc (length "/.git")))))
        (put repos-roots parent-dir (dflt-fn)))))
  #
  repos-roots)

########################################################################

(def config
  {:help "Recursively update git repositories"
   :fn (fn [_ _]
         # XXX: make configurable?
         (def repos-roots (find-repos-roots "."))

         (def orig-dir (os/cwd))

         (def problems @[])

         (eachp [root _] repos-roots
           (os/cd root)
           (print root)
           (def res (os/execute ["git" "pull" "--depth" "1"] :p))
           (cond
             # XXX: better handling would examine output as well to determine
             #      how to respond?
             (= 128 res)
             (do
               # XXX: following two things seem to help in divergent branches case
               #      where the original clone was shallow
               (os/execute ["git" "pull" "--unshallow"] :px)
               (os/execute ["git" "merge" "--allow-unrelated-histories"] :px))
             #
             (when (not (zero? res))
               (array/push problems root)
               (eprintf "git pull error for: %s" root)
               (eprintf "git exit code: %d" res)))
           (os/cd orig-dir))

         (when (pos? (length problems))
           (eprint "The following paths had some issue with updating:")
           (each issue problems
             (eprint issue))))})

