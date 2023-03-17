; NOTE: Assertions have been autogenerated by update_test_checks.py
; RUN: opt < %s -instsimplify -S | FileCheck %s

;; x * 0 ==> 0 when no-nans and no-signed-zero
define float @mul_zero_1(float %a) {
; CHECK-LABEL: @mul_zero_1(
; CHECK:         ret float 0.000000e+00
;
  %b = fmul nsz nnan float %a, 0.0
  ret float %b
}

define float @mul_zero_2(float %a) {
; CHECK-LABEL: @mul_zero_2(
; CHECK:         ret float 0.000000e+00
;
  %b = fmul fast float 0.0, %a
  ret float %b
}

;; x * 0 =/=> 0 when there could be nans or -0
define float @no_mul_zero_1(float %a) {
; CHECK-LABEL: @no_mul_zero_1(
; CHECK:         [[B:%.*]] = fmul nsz float %a, 0.000000e+00
; CHECK-NEXT:    ret float [[B]]
;
  %b = fmul nsz float %a, 0.0
  ret float %b
}

define float @no_mul_zero_2(float %a) {
; CHECK-LABEL: @no_mul_zero_2(
; CHECK:         [[B:%.*]] = fmul nnan float %a, 0.000000e+00
; CHECK-NEXT:    ret float [[B]]
;
  %b = fmul nnan float %a, 0.0
  ret float %b
}

define float @no_mul_zero_3(float %a) {
; CHECK-LABEL: @no_mul_zero_3(
; CHECK:         [[B:%.*]] = fmul float %a, 0.000000e+00
; CHECK-NEXT:    ret float [[B]]
;
  %b = fmul float %a, 0.0
  ret float %b
}

; fadd [nnan ninf] X, (fsub [nnan ninf] 0, X) ==> 0
;   where nnan and ninf have to occur at least once somewhere in this
;   expression
define float @fadd_fsub_0(float %a) {
; CHECK-LABEL: @fadd_fsub_0(
; CHECK:         [[NOFOLD:%.*]] = fsub float 0.000000e+00, %a
; CHECK-NEXT:    [[NO_ZERO:%.*]] = fadd nnan float [[NOFOLD]], %a
; CHECK-NEXT:    ret float [[NO_ZERO]]
;
; X + -X ==> 0
  %t1 = fsub nnan ninf float 0.0, %a
  %zero1 = fadd nnan ninf float %t1, %a

  %t2 = fsub nnan float 0.0, %a
  %zero2 = fadd ninf float %t2, %a

  %t3 = fsub nnan ninf float 0.0, %a
  %zero3 = fadd float %t3, %a

  %t4 = fsub float 0.0, %a
  %zero4 = fadd nnan ninf float %t4, %a

; Dont fold this
  %nofold = fsub float 0.0, %a
  %no_zero = fadd nnan float %nofold, %a

; Coalesce the folded zeros
  %zero5 = fadd float %zero1, %zero2
  %zero6 = fadd float %zero3, %zero4
  %zero7 = fadd float %zero5, %zero6

; Should get folded
  %ret = fadd nsz float %no_zero, %zero7

  ret float %ret
}

; fsub nnan x, x ==> 0.0
define float @fsub_x_x(float %a) {
; CHECK-LABEL: @fsub_x_x(
; CHECK:         [[NO_ZERO1:%.*]] = fsub ninf float %a, %a
; CHECK-NEXT:    [[NO_ZERO2:%.*]] = fsub float %a, %a
; CHECK-NEXT:    [[NO_ZERO:%.*]] = fadd float [[NO_ZERO1:%.*]], [[NO_ZERO2:%.*]]
; CHECK-NEXT:    ret float [[NO_ZERO]]
;
; X - X ==> 0
  %zero1 = fsub nnan float %a, %a

; Dont fold
  %no_zero1 = fsub ninf float %a, %a
  %no_zero2 = fsub float %a, %a
  %no_zero = fadd float %no_zero1, %no_zero2

; Should get folded
  %ret = fadd nsz float %no_zero, %zero1

  ret float %ret
}

; fsub nsz 0.0, (fsub 0.0, X) ==> X
define float @fsub_0_0_x(float %a) {
; CHECK-LABEL: @fsub_0_0_x(
; CHECK:         ret float %a
;
  %t1 = fsub float 0.0, %a
  %ret = fsub nsz float 0.0, %t1
  ret float %ret
}

; fadd nsz X, 0 ==> X
define float @nofold_fadd_x_0(float %a) {
; CHECK-LABEL: @nofold_fadd_x_0(
; CHECK:         [[NO_ZERO1:%.*]] = fadd ninf float %a, 0.000000e+00
; CHECK-NEXT:    [[NO_ZERO2:%.*]] = fadd nnan float %a, 0.000000e+00
; CHECK-NEXT:    [[NO_ZERO:%.*]] = fadd float [[NO_ZERO1:%.*]], [[NO_ZERO2:%.*]]
; CHECK-NEXT:    ret float [[NO_ZERO]]
;
; Dont fold
  %no_zero1 = fadd ninf float %a, 0.0
  %no_zero2 = fadd nnan float %a, 0.0
  %no_zero = fadd float %no_zero1, %no_zero2
  ret float %no_zero
}

; fdiv nsz nnan 0, X ==> 0
define double @fdiv_zero_by_x(double %X) {
; CHECK-LABEL: @fdiv_zero_by_x(
; CHECK:         ret double 0.000000e+00
;
; 0 / X -> 0
  %r = fdiv nnan nsz double 0.0, %X
  ret double %r
}

define float @fdiv_self(float %f) {
; CHECK-LABEL: @fdiv_self(
; CHECK:         ret float 1.000000e+00
;
  %div = fdiv nnan float %f, %f
  ret float %div
}

define float @fdiv_self_invalid(float %f) {
; CHECK-LABEL: @fdiv_self_invalid(
; CHECK:         [[DIV:%.*]] = fdiv float %f, %f
; CHECK-NEXT:    ret float [[DIV]]
;
  %div = fdiv float %f, %f
  ret float %div
}

define float @fdiv_neg1(float %f) {
; CHECK-LABEL: @fdiv_neg1(
; CHECK:         ret float -1.000000e+00
;
  %neg = fsub fast float -0.000000e+00, %f
  %div = fdiv nnan float %neg, %f
  ret float %div
}

define float @fdiv_neg2(float %f) {
; CHECK-LABEL: @fdiv_neg2(
; CHECK:         ret float -1.000000e+00
;
  %neg = fsub fast float 0.000000e+00, %f
  %div = fdiv nnan float %neg, %f
  ret float %div
}

define float @fdiv_neg_invalid(float %f) {
; CHECK-LABEL: @fdiv_neg_invalid(
; CHECK:         [[NEG:%.*]] = fsub fast float -0.000000e+00, %f
; CHECK-NEXT:    [[DIV:%.*]] = fdiv float [[NEG]], %f
; CHECK-NEXT:    ret float [[DIV]]
;
  %neg = fsub fast float -0.000000e+00, %f
  %div = fdiv float %neg, %f
  ret float %div
}

define float @fdiv_neg_swapped1(float %f) {
; CHECK-LABEL: @fdiv_neg_swapped1(
; CHECK:         ret float -1.000000e+00
;
  %neg = fsub float -0.000000e+00, %f
  %div = fdiv nnan float %f, %neg
  ret float %div
}

define float @fdiv_neg_swapped2(float %f) {
; CHECK-LABEL: @fdiv_neg_swapped2(
; CHECK:         ret float -1.000000e+00
;
  %neg = fsub float 0.000000e+00, %f
  %div = fdiv nnan float %f, %neg
  ret float %div
}
