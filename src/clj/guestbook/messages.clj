(ns guestbook.messages
  (:require [guestbook.db.core :as db]
            [guestbook.validation :refer [validate-message]]
            [conman.core :as conman]))

(defn message-list []
  {:messages (vec (db/get-messages))})

(defn messages-by-author [author]
  {:messages (vec (db/get-messages-by-author {:author author}))})

(defn save-message! [{{:keys [display-name]} :profile
                      :keys [login]}
                     message]
  (if-let [errors (validate-message message)]
    (throw (ex-info "Message is invalid"
                    {:guestbook/error-id :validation
                     :errors errors}))
    (let [tags (map second (re-seq #"(?<=\s|^)#([-\w]+)(?=\s|$)" (:message message)))]
      (conman/with-transaction [db/*db*]
        (let [post-id (:id
                       (db/save-message!  (assoc message
                                                       :author login
                                                       :name (or display-name login)
                                                       :parent (:parent message))))]
          (db/get-timeline-post {:post post-id
                                         :user login
                                         :is_boost false}))))))

(defn get-message [post-id]
  (db/get-message {:id post-id}))

(defn get-replies [id]
  (db/get-replies {:id id}))

(defn boost-message [{{:keys [display-name]} :profile
                      :keys [login]} post-id poster]
  (conman/with-transaction [db/*db*]
    (db/boost-post! {:post post-id
                     :poster poster
                     :user login})
    (db/get-timeline-post {:post post-id
                           :user login
                           :is_boost true})))

(defn timeline []
  {:messages (vec (db/get-timeline))})

(defn timeline-for-poster [poster]
  {:messages (vec (db/get-timeline-for-poster {:poster poster}))})

(defn get-parents [id]
  (db/get-parents {:id id}))

(defn get-feed-for-tag [tag]
  {:messages
   (db/get-feed-for-tag {:tag tag})})

(defn get-feed [feed-map]
  (when-not (every? #(re-matches #"[-\w]+" %) (:tags feed-map))
    (throw (ex-info "Tags must only contain alphanumeric characters, dashes, or underscores!" feed-map)))
  {:messages
   (db/get-feed (merge {:follows []
                        :tags []}
                       feed-map))})
