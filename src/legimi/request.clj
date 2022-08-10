(ns legimi.request
  (:require [clj-http.client :as client]
            [clojure.java.io :as io]))

(def url "https://app.legimi.pl/svc/sync/core.aspx")

(defn request
  [url body-seq]
  (client/post url
               {:body (byte-array body-seq)
                :as :byte-array}))
(defn- now
  []
  (quot (System/currentTimeMillis) 1000))

(defn- get-range
  [from len]
  [from (dec (min (+ from 81920) len))])

(defn download
  [url size filename]
  (with-open [w (io/output-stream filename)]
    (loop [[from to] (get-range 0 size)]
      (when (< from to)
        (let [book-part (client/get (format "%s&ts=%s" url (now))
                                    {:headers {"Range" (format "bytes=%d-%d" from to)}
                                     :as :byte-array})]
          (.write w (:body book-part)))
        (recur (get-range (inc to) size))))))
