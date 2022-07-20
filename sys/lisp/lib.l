(defmacro (if pred thenexpr elseexpr)
    `(cond (,pred ,thenexpr)
           (else  ,elseexpr)))
            
