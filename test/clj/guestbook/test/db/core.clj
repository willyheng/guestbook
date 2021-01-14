(ns guestbook.test.db.core
  (:require
   [guestbook.db.core :refer [*db*] :as db]
   [java-time.pre-java8]
   [luminus-migrations.core :as migrations]
   [clojure.test :refer :all]
   [clojure.java.jdbc :as jdbc]
   [guestbook.config :refer [env]]
   [mount.core :as mount]))

;; Integration tests commented out as Postgresql code does not work well with h2
;; (use-fixtures
;;   :once
;;   (fn [f]
;;     (mount/start
;;      #'guestbook.config/env
;;      #'guestbook.db.core/*db*)
;;     (migrations/migrate ["migrate"] (select-keys env [:database-url]))
;;     (f)))

;; (deftest test-messages
;;   (jdbc/with-db-transaction [t-conn *db*]
;;     (jdbc/db-set-rollback-only! t-conn)
;;     (is (= 1 (db/save-message!
;;               t-conn
;;               {:name "Sabrina"
;;                :message "Hello World"}
;;               {:connection t-conn})))
;;     (is (= {:name "Sabrina"
;;             :message "Hello World"}
;;            (-> (db/get-messages t-conn {})
;;                (first)
;;                (select-keys [:name :message]))))))
