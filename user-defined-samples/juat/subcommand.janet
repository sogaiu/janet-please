(def config
  {:help "Run juat tests."
   :rules []
   :fn (fn [_meta _args]
         (os/execute ["janet"
                      (string (os/getenv "HOME")
                              "/"
                              "src/"
                              "janet-usages-as-tests/"
                              "janet-usages-as-tests/"
                              "make-and-run-tests.janet" )
                      (os/cwd)]
                     :px))})

