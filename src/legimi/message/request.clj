(ns legimi.message.request
  (:require [legimi.byte :as b]))

(def version "1.3.4 Windows")
(def login-header        [0x11 0x00 0x00 0x00 0x50 0x00 0x62 0x00 0x00 0x00])
(def book-request-header [0x11 0x00 0x00 0x00 0xc8 0x00 0x40 0x00 0x00 0x00])

(defn- make-part
  [n bytes]
  (concat (b/short->lsbytes n) (b/bytes+len bytes)))

(defn- parts
  [n]
  (b/short->lsbytes n))

(defn make-login-request-body
  [login password]
  (concat login-header
          (parts 6)
          (make-part 4 (repeat 4 0x00))
          (make-part 2 [0x57 0xc1 0x1b 0x00 0x00 0x00 0x00 0x00])
          (make-part 3 (b/str->bytes version))
          (make-part 1 (b/str->bytes password))
          (make-part 0 (b/str->bytes login))
          (make-part 5 (repeat 8 0x00))))

(defn make-book-request-body
  [token book-number]
  (concat book-request-header
          (b/long->lsbytes book-number)
          (make-part 2 [])
          [0x00 0x00]
          token
          [0x00 0x00]
          (repeat 8 0xff)
          (make-part 1 [])))

