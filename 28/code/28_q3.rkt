#lang racket/base

; inorder-values : (or/c '() (list/c any/c list? list?)) list? -> list?
; Returns the values of tree in inorder (left subtree, node, right subtree)
; prepended onto tail. For the empty tree (), returns tail.
(define (inorder-values tree tail)
  (if (null? tree)
      tail
      (inorder-values (cadr tree)
                      (cons (car tree)
                            (inorder-values (caddr tree) tail)))))
