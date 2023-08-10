(import jplz/debug)

(def deprintf debug/deprintf)

########################################################################

(def config
  {:help "Remove trailing newlines from end of file."
   :rules [:file-path {:help "File to examine and may be change"
                       :req? true}]
   :fn (fn [_meta args]
         (def file-path
           (get-in args [:params :file-path]))
         (deprintf "%p" file-path)
         (def stat (os/stat file-path))
         # only examine ordinary files
         (when (= :file (get stat :mode))
           (def file-size (get stat :size))
           (var num-nls 0)
           (with [f (file/open file-path)]
             (var file-pos (dec file-size))
             (while (>= file-pos 0)
               (file/seek f :set file-pos)
               (-- file-pos)
               (def byte-buf (file/read f 1))
               (if (= (chr "\n")
                      (first byte-buf))
                 (++ num-nls)
                 (break))))
           # only modify files with trailing newlines
           (when (pos? num-nls)
             # XXX: memory-constrained and doesn't fail well?
             (spit file-path
                   (-> (slurp file-path)
                       (slice 0 (- file-size num-nls)))))))})

