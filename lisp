(defun area-of-circle ()
  (format t "~%Enter Radius: ")
  (let* ((radius (read))
         (area (* pi radius radius)))
    (format t "~%Radius = ~F~%Area = ~F~%" radius area)))

(area-of-circle)
[23bcs098@mepcolinux ex10]$cat calc.lisp
(defun calculator ()
  (loop
    (format t "~%--- Calculator Menu ---~%")
    (format t "1. Add~%2. Subtract~%3. Multiply~%4. Divide~%5. Exit~%")
    (format t "Enter choice: ")
    (finish-output)

    (let ((choice (read)))
      (if (= choice 5)
          (progn
            (format t "Exiting...~%")
            (return))

          (progn
            (format t "Enter two numbers: ")
            (finish-output)
            (let ((a (read))
                  (b (read)))

              (cond
                ((= choice 1)
                 (format t "Result = ~a~%" (+ a b)))

                ((= choice 2)
                 (format t "Result = ~a~%" (- a b)))

                ((= choice 3)
                 (format t "Result = ~a~%" (* a b)))

                ((= choice 4)
                 (if (= b 0)
                     (format t "Error: Division by zero~%")
                     (format t "Result = ~a~%" (/ a b))))

                (t
                 (format t "Invalid choice~%")))))))))

(calculator)
[23bcs098@mepcolinux ex10]$cat lcm.lisp
(defun my-gcd (a b)
  (if (= b 0)
      a
      (my-gcd b (mod a b))))

(defun my-lcm (a b)
  (/ (* a b) (my-gcd a b)))

(defun main ()
  (format t "Enter two numbers: ")
  (finish-output)
  (let ((a (read))
        (b (read)))
    (format t "GCD = ~a~%" (my-gcd a b))
    (format t "LCM = ~a~%" (my-lcm a b))))

(main)
[23bcs098@mepcolinux ex10]$cat fib.lisp
(defun fib-series (n)
  (let ((a 0) (b 1))
    (dotimes (i (+ n 1))
      (format t "~a " a)
      (psetq a b
             b (+ a b)))))

(defun main ()
  (format t "Enter n: ")
  (finish-output)
  (let ((n (read)))
    (fib-series n)
    (terpri)))   ;; move to next line

(main)
[23bcs098@mepcolinux ex10]$cat pal.lisp
(defun palindrome (n)
  (let ((original n)
        (rev 0))
    (loop while (> n 0) do
         (setq rev (+ (* rev 10) (mod n 10)))
         (setq n (floor n 10)))
    (if (= original rev)
        (format t "Palindrome~%")
        (format t "Not Palindrome~%"))))

(defun main ()
  (format t "Enter number: ")
  (finish-output)
  (let ((n (read)))
    (palindrome n)))

(main)
