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

;; (insert-if-short x lst n) -> list
;; x: any atom; lst: a (possibly nested) proper list with no dotted pairs;
;; n: an integer, n >= 0.
;; Returns a copy of lst in which x is placed at the front of every list
;; (the top-level list, every sublist, and every empty list) whose original
;; top-level length is less than n. Atoms are returned unchanged.
;; Reading: build the transformer (make-inserter x len-ok?) whose length
;; predicate is "less than n", and apply it to lst. make-inserter measures
;; each original list with my-length before inserting, treats () as a list,
;; and never revisits the inserted x, so those rules carry over unchanged.
;; Depends on: make-inserter (which uses my-length and my-map).
(define (insert-if-short x lst n)
  ((make-inserter x (lambda (len) (< len n))) lst))

;; (make-inserter x len-ok?) -> (lambda (lst) ...)
;; x: any atom; len-ok?: a one-argument predicate on a non-negative integer.
;; Returns a function of one (possibly nested) proper list that places x at
;; the front of every list (the given list, every sublist, and every empty
;; list) whose original top-level length satisfies len-ok?. Atoms are
;; returned unchanged.
;; Recursive reading:
;;   walk-list l: measure len = (my-length l) on the original l first, then
;;     transform each element with walk-elem via my-map; if (len-ok? len),
;;     cons x onto the transformed elements. x is added after the elements
;;     are transformed, so it is never visited again.
;;   walk-elem e: () or a pair is a list, so recurse with walk-list (() must
;;     be tested with null?, since (pair? '()) is #f); anything else is an
;;     atom and is returned as is.
;; len-ok? is called exactly once per list. Wide lists use constant stack
;; (my-length and my-map are tail-recursive); the only non-tail recursion is
;; one walk-list call per nesting level.
;; Depends on: my-length, my-map.
(define (make-inserter x len-ok?)
  (letrec ((walk-list
            (lambda (l)
              (let* ((len (my-length l))
                     (children (my-map walk-elem l)))
                (if (len-ok? len)
                    (cons x children)
                    children))))
           (walk-elem
            (lambda (e)
              (if (or (null? e) (pair? e))
                  (walk-list e)
                  e))))
    walk-list))
