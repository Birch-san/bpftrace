; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>
%printf_t = type { i64, i64 }
%printf_t.0 = type { i64, i64 }
%printf_t.1 = type { i64, i64 }
%printf_t.2 = type { i64, i64 }

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64, i64) #0

define i64 @BEGIN(i8*) section "s_BEGIN_1" {
entry:
  %helper_error_t29 = alloca %helper_error_t
  %key24 = alloca i32
  %helper_error_t19 = alloca %helper_error_t
  %key14 = alloca i32
  %helper_error_t9 = alloca %helper_error_t
  %key4 = alloca i32
  %helper_error_t = alloca %helper_error_t
  %key = alloca i32
  %"$x" = alloca i64
  %1 = bitcast i64* %"$x" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %1)
  store i64 0, i64* %"$x"
  %2 = bitcast i64* %"$x" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %2)
  store i64 10, i64* %"$x"
  %3 = bitcast i32* %key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %3)
  store i32 0, i32* %key
  %pseudo = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %lookup_fmtstr_map = call %printf_t* inttoptr (i64 1 to %printf_t* (i64, i32*)*)(i64 %pseudo, i32* %key)
  %4 = sext %printf_t* %lookup_fmtstr_map to i32
  %5 = icmp ne i32 %4, 0
  br i1 %5, label %helper_merge, label %helper_failure

helper_failure:                                   ; preds = %entry
  %6 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %6)
  %7 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 0
  store i64 30006, i64* %7
  %8 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 1
  store i64 0, i64* %8
  %9 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 2
  store i32 %4, i32* %9
  %10 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 3
  store i8 1, i8* %10
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo1, i64 4294967295, %helper_error_t* %helper_error_t, i64 21)
  %11 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %11)
  ret i64 0

helper_merge:                                     ; preds = %entry
  %12 = bitcast %printf_t* %lookup_fmtstr_map to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %12, i64 0, i64 16, i1 false)
  %13 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i32 0, i32 0
  store i64 0, i64* %13
  %14 = load i64, i64* %"$x"
  %15 = add i64 %14, 1
  store i64 %15, i64* %"$x"
  %16 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i32 0, i32 1
  store i64 %14, i64* %16
  %pseudo2 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output3 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %printf_t*, i64)*)(i8* %0, i64 %pseudo2, i64 4294967295, %printf_t* %lookup_fmtstr_map, i64 16)
  %17 = bitcast %printf_t* %lookup_fmtstr_map to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %17)
  %18 = bitcast i32* %key4 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %18)
  store i32 0, i32* %key4
  %pseudo5 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %lookup_fmtstr_map6 = call %printf_t.0* inttoptr (i64 1 to %printf_t.0* (i64, i32*)*)(i64 %pseudo5, i32* %key4)
  %19 = sext %printf_t.0* %lookup_fmtstr_map6 to i32
  %20 = icmp ne i32 %19, 0
  br i1 %20, label %helper_merge8, label %helper_failure7

helper_failure7:                                  ; preds = %helper_merge
  %21 = bitcast %helper_error_t* %helper_error_t9 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %21)
  %22 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t9, i64 0, i32 0
  store i64 30006, i64* %22
  %23 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t9, i64 0, i32 1
  store i64 1, i64* %23
  %24 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t9, i64 0, i32 2
  store i32 %19, i32* %24
  %25 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t9, i64 0, i32 3
  store i8 1, i8* %25
  %pseudo10 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output11 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo10, i64 4294967295, %helper_error_t* %helper_error_t9, i64 21)
  %26 = bitcast %helper_error_t* %helper_error_t9 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %26)
  ret i64 0

helper_merge8:                                    ; preds = %helper_merge
  %27 = bitcast %printf_t.0* %lookup_fmtstr_map6 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %27, i64 0, i64 16, i1 false)
  %28 = getelementptr %printf_t.0, %printf_t.0* %lookup_fmtstr_map6, i32 0, i32 0
  store i64 1, i64* %28
  %29 = load i64, i64* %"$x"
  %30 = add i64 %29, 1
  store i64 %30, i64* %"$x"
  %31 = getelementptr %printf_t.0, %printf_t.0* %lookup_fmtstr_map6, i32 0, i32 1
  store i64 %30, i64* %31
  %pseudo12 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output13 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %printf_t.0*, i64)*)(i8* %0, i64 %pseudo12, i64 4294967295, %printf_t.0* %lookup_fmtstr_map6, i64 16)
  %32 = bitcast %printf_t.0* %lookup_fmtstr_map6 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %32)
  %33 = bitcast i32* %key14 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %33)
  store i32 0, i32* %key14
  %pseudo15 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %lookup_fmtstr_map16 = call %printf_t.1* inttoptr (i64 1 to %printf_t.1* (i64, i32*)*)(i64 %pseudo15, i32* %key14)
  %34 = sext %printf_t.1* %lookup_fmtstr_map16 to i32
  %35 = icmp ne i32 %34, 0
  br i1 %35, label %helper_merge18, label %helper_failure17

helper_failure17:                                 ; preds = %helper_merge8
  %36 = bitcast %helper_error_t* %helper_error_t19 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %36)
  %37 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t19, i64 0, i32 0
  store i64 30006, i64* %37
  %38 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t19, i64 0, i32 1
  store i64 2, i64* %38
  %39 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t19, i64 0, i32 2
  store i32 %34, i32* %39
  %40 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t19, i64 0, i32 3
  store i8 1, i8* %40
  %pseudo20 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output21 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo20, i64 4294967295, %helper_error_t* %helper_error_t19, i64 21)
  %41 = bitcast %helper_error_t* %helper_error_t19 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %41)
  ret i64 0

helper_merge18:                                   ; preds = %helper_merge8
  %42 = bitcast %printf_t.1* %lookup_fmtstr_map16 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %42, i64 0, i64 16, i1 false)
  %43 = getelementptr %printf_t.1, %printf_t.1* %lookup_fmtstr_map16, i32 0, i32 0
  store i64 2, i64* %43
  %44 = load i64, i64* %"$x"
  %45 = sub i64 %44, 1
  store i64 %45, i64* %"$x"
  %46 = getelementptr %printf_t.1, %printf_t.1* %lookup_fmtstr_map16, i32 0, i32 1
  store i64 %44, i64* %46
  %pseudo22 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output23 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %printf_t.1*, i64)*)(i8* %0, i64 %pseudo22, i64 4294967295, %printf_t.1* %lookup_fmtstr_map16, i64 16)
  %47 = bitcast %printf_t.1* %lookup_fmtstr_map16 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %47)
  %48 = bitcast i32* %key24 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %48)
  store i32 0, i32* %key24
  %pseudo25 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %lookup_fmtstr_map26 = call %printf_t.2* inttoptr (i64 1 to %printf_t.2* (i64, i32*)*)(i64 %pseudo25, i32* %key24)
  %49 = sext %printf_t.2* %lookup_fmtstr_map26 to i32
  %50 = icmp ne i32 %49, 0
  br i1 %50, label %helper_merge28, label %helper_failure27

helper_failure27:                                 ; preds = %helper_merge18
  %51 = bitcast %helper_error_t* %helper_error_t29 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %51)
  %52 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t29, i64 0, i32 0
  store i64 30006, i64* %52
  %53 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t29, i64 0, i32 1
  store i64 3, i64* %53
  %54 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t29, i64 0, i32 2
  store i32 %49, i32* %54
  %55 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t29, i64 0, i32 3
  store i8 1, i8* %55
  %pseudo30 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output31 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo30, i64 4294967295, %helper_error_t* %helper_error_t29, i64 21)
  %56 = bitcast %helper_error_t* %helper_error_t29 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %56)
  ret i64 0

helper_merge28:                                   ; preds = %helper_merge18
  %57 = bitcast %printf_t.2* %lookup_fmtstr_map26 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %57, i64 0, i64 16, i1 false)
  %58 = getelementptr %printf_t.2, %printf_t.2* %lookup_fmtstr_map26, i32 0, i32 0
  store i64 3, i64* %58
  %59 = load i64, i64* %"$x"
  %60 = sub i64 %59, 1
  store i64 %60, i64* %"$x"
  %61 = getelementptr %printf_t.2, %printf_t.2* %lookup_fmtstr_map26, i32 0, i32 1
  store i64 %60, i64* %61
  %pseudo32 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output33 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %printf_t.2*, i64)*)(i8* %0, i64 %pseudo32, i64 4294967295, %printf_t.2* %lookup_fmtstr_map26, i64 16)
  %62 = bitcast %printf_t.2* %lookup_fmtstr_map26 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %62)
  ret i64 0
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1) #1

attributes #0 = { nounwind }
attributes #1 = { argmemonly nounwind }
