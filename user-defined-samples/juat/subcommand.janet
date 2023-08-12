(import ./make-and-run-tests :as mart)

(def config
  {:help "Run juat tests."
   :rules []
   :fn (fn [_meta _args]
         (mart/main nil (os/cwd)))})

