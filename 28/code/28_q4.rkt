#lang racket/base

;; (my-reverse lst) -> list
;; lst: a proper list (elements may be atoms or lists; they are not inspected).
;; Returns the top-level elements of lst in reverse order.
;; Recursive reading: walk lst with an accumulator acc, initially ().
;;   Base case: rest is () -> acc holds every element, reversed.
;;   Step: move (car rest) onto the front of acc and continue on (cdr rest).
;; The recursive call is in tail position, so 10,000-element lists use
;; constant stack space. Used by my-map to restore element order.
(define (my-reverse lst)
  (let loop ((rest lst) (acc '()))
    (if (null? rest)
        acc
        (loop (cdr rest) (cons (car rest) acc)))))

