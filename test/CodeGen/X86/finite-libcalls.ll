; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-pc-linux-gnu     | FileCheck %s --check-prefix=CHECK --check-prefix=GNU
; RUN: llc < %s -mtriple=x86_64-pc-windows-msvc  | FileCheck %s --check-prefix=CHECK --check-prefix=WIN

; PR35672 - https://bugs.llvm.org/show_bug.cgi?id=35672
; FIXME: We would not need the function-level attributes if FMF were propagated to DAG nodes for this case.

define float @exp_f32(float %x) #0 {
; CHECK-LABEL: exp_f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    jmp expf # TAILCALL
  %exp = tail call nnan ninf float @llvm.exp.f32(float %x)
  ret float %exp
}

define double @exp_f64(double %x) #0 {
; CHECK-LABEL: exp_f64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    jmp exp # TAILCALL
  %exp = tail call nnan ninf double @llvm.exp.f64(double %x)
  ret double %exp
}

define x86_fp80 @exp_f80(x86_fp80 %x) #0 {
; GNU-LABEL: exp_f80:
; GNU:       # %bb.0:
; GNU-NEXT:    subq $24, %rsp
; GNU-NEXT:    fldt {{[0-9]+}}(%rsp)
; GNU-NEXT:    fstpt (%rsp)
; GNU-NEXT:    callq expl
; GNU-NEXT:    addq $24, %rsp
; GNU-NEXT:    retq
;
; WIN-LABEL: exp_f80:
; WIN:       # %bb.0:
; WIN-NEXT:    subq $56, %rsp
; WIN-NEXT:    fldt {{[0-9]+}}(%rsp)
; WIN-NEXT:    fstpt {{[0-9]+}}(%rsp)
; WIN-NEXT:    callq expl
; WIN-NEXT:    addq $56, %rsp
; WIN-NEXT:    retq
  %exp = tail call nnan ninf x86_fp80 @llvm.exp.f80(x86_fp80 %x)
  ret x86_fp80 %exp
}

declare float @llvm.exp.f32(float) #1
declare double @llvm.exp.f64(double) #1
declare x86_fp80 @llvm.exp.f80(x86_fp80) #1

attributes #0 = { nounwind "no-infs-fp-math"="true" "no-nans-fp-math"="true" }
attributes #1 = { nounwind readnone speculatable }

