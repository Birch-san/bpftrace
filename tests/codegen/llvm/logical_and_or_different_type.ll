; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>
%printf_t = type { i64, i64, i64, i64, i64 }

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64, i64) #0

define i64 @BEGIN(i8*) section "s_BEGIN_1" {
entry:
  %"struct Foo.m24" = alloca i32
  %"||_result23" = alloca i64
  %"struct Foo.m16" = alloca i32
  %"||_result" = alloca i64
  %"struct Foo.m14" = alloca i32
  %"&&_result13" = alloca i64
  %"struct Foo.m" = alloca i32
  %"&&_result" = alloca i64
  %helper_error_t6 = alloca %helper_error_t
  %key2 = alloca i32
  %helper_error_t = alloca %helper_error_t
  %key = alloca i32
  %1 = bitcast i32* %key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %1)
  store i32 0, i32* %key
  %pseudo = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %"lookup_$foo_map" = call [4 x i8]* inttoptr (i64 1 to [4 x i8]* (i64, i32*)*)(i64 %pseudo, i32* %key)
  %2 = sext [4 x i8]* %"lookup_$foo_map" to i32
  %3 = icmp ne i32 %2, 0
  br i1 %3, label %helper_merge, label %helper_failure

helper_failure:                                   ; preds = %entry
  %4 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %4)
  %5 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 0
  store i64 30006, i64* %5
  %6 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 1
  store i64 0, i64* %6
  %7 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 2
  store i32 %2, i32* %7
  %8 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 3
  store i8 1, i8* %8
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo1, i64 4294967295, %helper_error_t* %helper_error_t, i64 21)
  %9 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %9)
  ret i64 0

helper_merge:                                     ; preds = %entry
  %10 = bitcast [4 x i8]* %"lookup_$foo_map" to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %10, i64 0, i64 4, i1 false)
  %11 = bitcast [4 x i8]* %"lookup_$foo_map" to i8*
  %12 = bitcast i64 0 to i8 addrspace(64)*
  call void @llvm.memcpy.p0i8.p64i8.i64(i8* align 8 %11, i8 addrspace(64)* align 8 %12, i64 4, i1 false)
  %13 = bitcast i32* %key2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %13)
  store i32 0, i32* %key2
  %pseudo3 = call i64 @llvm.bpf.pseudo(i64 1, i64 3)
  %lookup_fmtstr_map = call %printf_t* inttoptr (i64 1 to %printf_t* (i64, i32*)*)(i64 %pseudo3, i32* %key2)
  %14 = sext %printf_t* %lookup_fmtstr_map to i32
  %15 = icmp ne i32 %14, 0
  br i1 %15, label %helper_merge5, label %helper_failure4

helper_failure4:                                  ; preds = %helper_merge
  %16 = bitcast %helper_error_t* %helper_error_t6 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %16)
  %17 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t6, i64 0, i32 0
  store i64 30006, i64* %17
  %18 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t6, i64 0, i32 1
  store i64 1, i64* %18
  %19 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t6, i64 0, i32 2
  store i32 %14, i32* %19
  %20 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t6, i64 0, i32 3
  store i8 1, i8* %20
  %pseudo7 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output8 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo7, i64 4294967295, %helper_error_t* %helper_error_t6, i64 21)
  %21 = bitcast %helper_error_t* %helper_error_t6 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %21)
  ret i64 0

helper_merge5:                                    ; preds = %helper_merge
  %22 = bitcast %printf_t* %lookup_fmtstr_map to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %22, i64 0, i64 40, i1 false)
  %23 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i32 0, i32 0
  store i64 0, i64* %23
  %24 = bitcast i64* %"&&_result" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %24)
  %25 = add [4 x i8]* %"lookup_$foo_map", i64 0
  %26 = bitcast i32* %"struct Foo.m" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %26)
  %probe_read = call i64 inttoptr (i64 4 to i64 (i32*, i32, [4 x i8]*)*)(i32* %"struct Foo.m", i32 4, [4 x i8]* %25)
  %27 = load i32, i32* %"struct Foo.m"
  %28 = sext i32 %27 to i64
  %29 = bitcast i32* %"struct Foo.m" to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %29)
  %lhs_true_cond = icmp ne i64 %28, 0
  br i1 %lhs_true_cond, label %"&&_lhs_true", label %"&&_false"

"&&_lhs_true":                                    ; preds = %helper_merge5
  br i1 false, label %"&&_true", label %"&&_false"

"&&_true":                                        ; preds = %"&&_lhs_true"
  store i64 1, i64* %"&&_result"
  br label %"&&_merge"

"&&_false":                                       ; preds = %"&&_lhs_true", %helper_merge5
  store i64 0, i64* %"&&_result"
  br label %"&&_merge"

"&&_merge":                                       ; preds = %"&&_false", %"&&_true"
  %30 = load i64, i64* %"&&_result"
  %31 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i32 0, i32 1
  store i64 %30, i64* %31
  %32 = bitcast i64* %"&&_result13" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %32)
  br i1 true, label %"&&_lhs_true9", label %"&&_false11"

"&&_lhs_true9":                                   ; preds = %"&&_merge"
  %33 = add [4 x i8]* %"lookup_$foo_map", i64 0
  %34 = bitcast i32* %"struct Foo.m14" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %34)
  %probe_read15 = call i64 inttoptr (i64 4 to i64 (i32*, i32, [4 x i8]*)*)(i32* %"struct Foo.m14", i32 4, [4 x i8]* %33)
  %35 = load i32, i32* %"struct Foo.m14"
  %36 = sext i32 %35 to i64
  %37 = bitcast i32* %"struct Foo.m14" to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %37)
  %rhs_true_cond = icmp ne i64 %36, 0
  br i1 %rhs_true_cond, label %"&&_true10", label %"&&_false11"

"&&_true10":                                      ; preds = %"&&_lhs_true9"
  store i64 1, i64* %"&&_result13"
  br label %"&&_merge12"

"&&_false11":                                     ; preds = %"&&_lhs_true9", %"&&_merge"
  store i64 0, i64* %"&&_result13"
  br label %"&&_merge12"

"&&_merge12":                                     ; preds = %"&&_false11", %"&&_true10"
  %38 = load i64, i64* %"&&_result13"
  %39 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i32 0, i32 2
  store i64 %38, i64* %39
  %40 = bitcast i64* %"||_result" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %40)
  %41 = add [4 x i8]* %"lookup_$foo_map", i64 0
  %42 = bitcast i32* %"struct Foo.m16" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %42)
  %probe_read17 = call i64 inttoptr (i64 4 to i64 (i32*, i32, [4 x i8]*)*)(i32* %"struct Foo.m16", i32 4, [4 x i8]* %41)
  %43 = load i32, i32* %"struct Foo.m16"
  %44 = sext i32 %43 to i64
  %45 = bitcast i32* %"struct Foo.m16" to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %45)
  %lhs_true_cond18 = icmp ne i64 %44, 0
  br i1 %lhs_true_cond18, label %"||_true", label %"||_lhs_false"

"||_lhs_false":                                   ; preds = %"&&_merge12"
  br i1 false, label %"||_true", label %"||_false"

"||_false":                                       ; preds = %"||_lhs_false"
  store i64 0, i64* %"||_result"
  br label %"||_merge"

"||_true":                                        ; preds = %"||_lhs_false", %"&&_merge12"
  store i64 1, i64* %"||_result"
  br label %"||_merge"

"||_merge":                                       ; preds = %"||_true", %"||_false"
  %46 = load i64, i64* %"||_result"
  %47 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i32 0, i32 3
  store i64 %46, i64* %47
  %48 = bitcast i64* %"||_result23" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %48)
  br i1 false, label %"||_true21", label %"||_lhs_false19"

"||_lhs_false19":                                 ; preds = %"||_merge"
  %49 = add [4 x i8]* %"lookup_$foo_map", i64 0
  %50 = bitcast i32* %"struct Foo.m24" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %50)
  %probe_read25 = call i64 inttoptr (i64 4 to i64 (i32*, i32, [4 x i8]*)*)(i32* %"struct Foo.m24", i32 4, [4 x i8]* %49)
  %51 = load i32, i32* %"struct Foo.m24"
  %52 = sext i32 %51 to i64
  %53 = bitcast i32* %"struct Foo.m24" to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %53)
  %rhs_true_cond26 = icmp ne i64 %52, 0
  br i1 %rhs_true_cond26, label %"||_true21", label %"||_false20"

"||_false20":                                     ; preds = %"||_lhs_false19"
  store i64 0, i64* %"||_result23"
  br label %"||_merge22"

"||_true21":                                      ; preds = %"||_lhs_false19", %"||_merge"
  store i64 1, i64* %"||_result23"
  br label %"||_merge22"

"||_merge22":                                     ; preds = %"||_true21", %"||_false20"
  %54 = load i64, i64* %"||_result23"
  %55 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i32 0, i32 4
  store i64 %54, i64* %55
  %pseudo27 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output28 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %printf_t*, i64)*)(i8* %0, i64 %pseudo27, i64 4294967295, %printf_t* %lookup_fmtstr_map, i64 40)
  %56 = bitcast %printf_t* %lookup_fmtstr_map to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %56)
  ret i64 0
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p64i8.i64(i8* nocapture writeonly, i8 addrspace(64)* nocapture readonly, i64, i1) #1

attributes #0 = { nounwind }
attributes #1 = { argmemonly nounwind }
