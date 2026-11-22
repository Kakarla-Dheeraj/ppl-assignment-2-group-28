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

; preorder-values : (or/c '() (list/c any/c list? list?)) list? -> list?
; Returns the values of tree in preorder (node, left subtree, right subtree)
; prepended onto tail. For the empty tree (), returns tail.
(define (preorder-values tree tail)
  (if (null? tree)
      tail
      (cons (car tree)
            (preorder-values (cadr tree)
                             (preorder-values (caddr tree) tail)))))

; postorder-values : (or/c '() (list/c any/c list? list?)) list? -> list?
; Returns the values of tree in postorder (left subtree, right subtree, node)
; prepended onto tail. For the empty tree (), returns tail.
(define (postorder-values tree tail)
  (if (null? tree)
      tail
      (postorder-values (cadr tree)
                        (postorder-values (caddr tree)
                                          (cons (car tree) tail)))))
