(ns legimi.message.response
  (:require [legimi.byte :as b]
            [clojure.string :as str]))

(defn- parse-response-part
  [remaining-parts]
  (when (seq remaining-parts)
    (let [[part remaining] (split-at 2 remaining-parts)
          [len remaining] (split-at 4 remaining)
          [content remaining] (split-at (b/lsbytes->num len) remaining)]
      [{:part part
        :content content}
       remaining])))

(defn- parse-response-parts
  [response-parts]
  (let [[parts-number response-parts] (split-at 2 response-parts)
        parts-number (b/lsbytes->num parts-number)]
    (loop [parts {}
           remaining-parts response-parts
           n parts-number]
      (if (zero? n) parts
          (if-let [[{:keys [part content]} remaining-parts] (parse-response-part remaining-parts)]
            (recur (assoc parts part content)
                   remaining-parts
                   (dec n))
            parts)))))

(defn- parse-response
  [response header-length]
  (let [[header parts] (split-at header-length response)]
    {:header header
     :parts (parse-response-parts parts)}))

(defn get-token
  [parsed-body]
  (get-in parsed-body [:parts (b/short->lsbytes 7)]))

(defn get-download-link
  [parsed-body]
  (str/join (map char (get-in parsed-body [:parts (b/short->lsbytes 0)]))))

(defn get-download-size
  [parsed-body]
  (-> parsed-body
      (get-in [:parts (b/short->lsbytes 2)])
      b/lsbytes->num))

(defn parse-login-response
  [login-response]
  (parse-response (:body login-response) 10))

(defn parse-book-response
  [book-response]
  (parse-response (:body book-response) 20))
