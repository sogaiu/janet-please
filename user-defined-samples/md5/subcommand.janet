(import jplz/debug)

(def deprintf debug/deprintf)

########################################################################

(import ./md5)

########################################################################

(def config
  {:help "Compute MD5 of a file."
   :rules [:file-path {:help "Input file"
                       :req? true}]
   :fn (fn [_meta args]
         (def file-path
           (get-in args [:params :file-path]))
         (deprintf "%p" file-path)
         (def stat (os/stat file-path))
         # only operate on ordinary files
         (when (= :file (get stat :mode))
           (print (md5/md5 (slurp file-path)))))})

