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

; tree-stats : (or/c '() (list/c any/c list? list?)) -> (list/c integer? integer?)
; Returns the list (height leaf-count) for tree.
; An empty tree gives (0 0); a leaf node gives (1 1).
(define (tree-stats tree)
  (cond
    [(null? tree) (list 0 0)]
    [(and (null? (cadr tree)) (null? (caddr tree))) (list 1 1)]
    [else
     (let ([left-stats (tree-stats (cadr tree))]
           [right-stats (tree-stats (caddr tree))])
       (list (+ 1 (max (car left-stats) (car right-stats)))
             (+ (cadr left-stats) (cadr right-stats))))]))

; print-inorder : (or/c '() (list/c any/c list? list?)) -> void?
; Prints on one line using display the list of values of tree in inorder,
; followed by a newline.
(define (print-inorder tree)
  (display (inorder-values tree '()))
  (newline))
