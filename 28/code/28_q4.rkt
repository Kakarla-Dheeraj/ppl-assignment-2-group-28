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


;; (my-length lst) -> non-negative integer
;; lst: a proper list (elements may be atoms or lists; they are not inspected).
;; Returns the number of top-level elements of lst; a sublist, including (),
;; counts as one element, and () itself has length 0.
;; Recursive reading: walk lst with a counter count, initially 0.
;;   Base case: rest is () -> count is the number of elements seen.
;;   Step: add 1 to count and continue on (cdr rest).
;; The recursive call is in tail position, so 10,000-element lists use
;; constant stack space.
(define (my-length lst)
  (let loop ((rest lst) (count 0))
    (if (null? rest)
        count
        (loop (cdr rest) (+ count 1)))))

;; (my-map f lst) -> list
;; f: a one-argument function; lst: a proper list.
;; Returns a list of the same length whose i-th element is (f e_i), where
;; e_i is the i-th top-level element of lst; f is called exactly once per
;; element, from left to right.
;; Recursive reading: walk lst with an accumulator acc, initially ().
;;   Base case: rest is () -> acc holds the results in reverse order, so
;;     (my-reverse acc) restores the original order.
;;   Step: cons (f (car rest)) onto acc and continue on (cdr rest).
;; The recursive call is in tail position and my-reverse is tail-recursive,
;; so 10,000-element lists use constant stack space (two linear passes).
;; Depends on: my-reverse.
(define (my-map f lst)
  (let loop ((rest lst) (acc '()))
    (if (null? rest)
        (my-reverse acc)
        (loop (cdr rest) (cons (f (car rest)) acc)))))
