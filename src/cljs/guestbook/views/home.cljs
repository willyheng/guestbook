(ns guestbook.views.home
  (:require
   [re-frame.core :as rf]
   [guestbook.messages :as messages]
   [guestbook.auth :as auth]))

(defn home []
  (let [messages (rf/subscribe [:messages/list])]
    (fn []
      (if @(rf/subscribe [:messages/loading?])
        [:div>div.row>div.span12>h3
         "Loading Messages..."]
        [:div.content>div.columns.is-centered>div.column.is-two-thirds
         [:div.columns>div.column
          [:h3 "Messages"]
          [messages/message-list messages]]
         [:div.columns>div.column
          [messages/reload-messages-button]]
         [:div.columns>div.column
          (case @(rf/subscribe [:auth/user-state])
            :loading
            [:div {:style {:width "5em"}}
             [:progress.progress.is-dark.is-small {:max 100} "30%"]]

            :authenticated
            [messages/message-form]

            :anonymous
            [:div.notification.is-clearfix
             [:span "Log in or create an account to post a message!"]
             [:div.buttons.is-pulled-right
              [auth/login-button]
              [auth/register-button]]])]]))))
