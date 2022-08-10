(ns legimi.byte
  (:require [clojure.string :as str]))

(defn- byte-n
  "Returns nth byte of x."
  [x n]
  (let [mask (bit-shift-left 0xff (* 8 n))
        div (bit-shift-left 0x1 (* 8 n))]
    (/ (bit-and x mask) div)))

(defn- n->lsbytes
  [n x]
  (map #(byte-n x %) (range n)))

(defn short->lsbytes
  [x]
  (n->lsbytes 2 x))

(defn int->lsbytes
  "Returns sequence of 4 bytes of x in LSB order."
  [x]
  (n->lsbytes 4 x))

(defn long->lsbytes
  "Returns sequence of 8 bytes of x in LSB order."
  [x]
  (n->lsbytes 8 x))

(defn lsbytes->num
  "Converts sequence of bytes in LSB order into number."
  [lsbytes]
  (apply + (map (fn [b i] (bit-shift-left b (* 8 i))) lsbytes (range))))

(defn print-hex
  [ba]
  (println)
  (println
   (->> ba
        (map (comp #(format "%02x" %) unchecked-byte))
        (partition-all 16)
        (map #(str/join " " %))
        (str/join "\n"))))

(defn bytes+len
  "Returns vector of bytes preceded by bytes length in LSB order."
  [bs]
  (concat (int->lsbytes (count bs)) bs))

(defn str->bytes
  [s]
  (map int s))
