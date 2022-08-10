(ns legimi.core
  (:require
   [legimi.message.request :refer [make-book-request-body
                                   make-login-request-body]]
   [legimi.message.response :refer [get-download-link
                                    get-download-size
                                    get-token
                                    parse-book-response
                                    parse-login-response]]
   [legimi.request :refer [download
                           request
                           url]])
  (:gen-class))

(defn -main
  [& args]
  (let [book-id (Long/parseLong (first args))
        login (System/getenv "LEGIMI_LOGIN")
        password (System/getenv "LEGIMI_PASS")
        token (-> url
                  (request (make-login-request-body login password))
                  parse-login-response
                  get-token)
        book-details (-> url
                         (request (make-book-request-body token book-id))
                         parse-book-response)
        book-size (get-download-size book-details)
        book-url (get-download-link book-details)]
    (when (and (seq book-url) (pos? book-size))
      (println (format "Downloading book: %d" book-id))
      (download book-url book-size (format "%d.mobi" book-id))
      (println "Download completed."))))

