(ns guestbook.auth
  (:require
   [buddy.hashers :as hashers]
   [clojure.java.jdbc :as jdbc]
   [guestbook.db.core :as db]))

(defn create-user! [login password]
  (jdbc/with-db-transaction [t-conn db/*db*]
    (if-not (empty? (db/get-user-for-auth* t-conn {:login login}))
      (throw (ex-info "User already exists!"
                      {:guestbook/error-id ::duplicate-user
                       :error "User already exists!"}))
      (db/create-user! t-conn
                       {:login login
                        :password (hashers/derive password)}))))

(defn authenticate-user [login password]
  (jdbc/with-db-transaction [t-conn db/*db*]
    (let [{hashed :password :as user}  (db/get-user-for-auth* t-conn {:login login})]
      (when (hashers/check password hashed)
        (dissoc user :password)))))
