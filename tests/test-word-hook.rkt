#lang racket

(require compatibility/defmacro
         "../interpreter/interpreter.rkt"
	 "../compiler/compile.rkt"
         "../compiler/assemble.rkt"
         "../compiler/bootstream.rkt"
         "../interpreter/stack.rkt")

(define chip (new-ga144 "host"))

(define code "node 705
0 if 
: b dup + ;
: a for b next ;
: c 10 a ;
then
")

(define compiled (compile code))
(define assembled (assemble compiled))

(define node (get-node chip 705))

(send chip load assembled)

(define b-counter 0)
(send node set-word-hook-fn
      "b"
      (lambda () (set! b-counter (add1 b-counter)))
)

(enter-cli-on-breakpoint #t)

(step*)
(define loop-count 15)
(send node d-push! loop-count)
(send node call-word! "a")
(step*)
(printf "b-counter = ~a\n" b-counter)

(unless (equal? b-counter (add1 loop-count))
  (raise (format "check failed: ~a == ~a" b-counter (add1 loop-count))))