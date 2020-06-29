; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>
%printf_t = type <{ i64, i64, i64, i64, i64 }>

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64, i64) #0

define i64 @BEGIN(i8*) local_unnamed_addr section "s_BEGIN_1" {
entry:
  %"struct Foo.m26" = alloca i32, align 4
  %"struct Foo.m18" = alloca i32, align 4
  %"struct Foo.m16" = alloca i32, align 4
  %"struct Foo.m" = alloca i32, align 4
  %helper_error_t6 = alloca %helper_error_t, align 8
  %key2 = alloca i32, align 4
  %helper_error_t = alloca %helper_error_t, align 8
  %key = alloca i32, align 4
  %1 = bitcast i32* %key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %1)
  store i32 0, i32* %key, align 4
  %pseudo = tail call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %"lookup_$foo_map" = call [4 x i8]* inttoptr (i64 1 to [4 x i8]* (i64, i32*)*)(i64 %pseudo, i32* nonnull %key)
  %2 = icmp eq [4 x i8]* %"lookup_$foo_map", null
  br i1 %2, label %helper_failure, label %helper_merge

helper_failure:                                   ; preds = %entry
  %3 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %3)
  %4 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 0
  store i64 30006, i64* %4, align 8
  %5 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 1
  store i64 0, i64* %5, align 8
  %6 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 2
  store i32 0, i32* %6, align 8
  %7 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 3
  store i8 1, i8* %7, align 4
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo1, i64 4294967295, %helper_error_t* nonnull %helper_error_t, i64 21)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %3)
  ret i64 0

helper_merge:                                     ; preds = %entry
  %probe_read = call i64 inttoptr (i64 4 to i64 ([4 x i8]*, i32, [4 x i8]*)*)([4 x i8]* nonnull %"lookup_$foo_map", i32 4, [4 x i8]* inttoptr (i64 140695077246944 to [4 x i8]*))
  %8 = bitcast [4 x i8]* %"lookup_$foo_map" to i32*
  %9 = load i32, i32 addrspace(64)* null, align 536870912
  store i32 %9, i32* %8, align 1
  %10 = bitcast i32* %key2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %10)
  store i32 0, i32* %key2, align 4
  %pseudo3 = call i64 @llvm.bpf.pseudo(i64 1, i64 3)
  %lookup_fmtstr_map = call %printf_t* inttoptr (i64 1 to %printf_t* (i64, i32*)*)(i64 %pseudo3, i32* nonnull %key2)
  %11 = icmp eq %printf_t* %lookup_fmtstr_map, null
  br i1 %11, label %helper_failure4, label %helper_merge5

helper_failure4:                                  ; preds = %helper_merge
  %12 = bitcast %helper_error_t* %helper_error_t6 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %12)
  %13 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t6, i64 0, i32 0
  store i64 30006, i64* %13, align 8
  %14 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t6, i64 0, i32 1
  store i64 1, i64* %14, align 8
  %15 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t6, i64 0, i32 2
  store i32 0, i32* %15, align 8
  %16 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t6, i64 0, i32 3
  store i8 1, i8* %16, align 4
  %pseudo7 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output8 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo7, i64 4294967295, %helper_error_t* nonnull %helper_error_t6, i64 21)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %12)
  ret i64 0

helper_merge5:                                    ; preds = %helper_merge
  %probe_read9 = call i64 inttoptr (i64 4 to i64 (%printf_t*, i32, %printf_t*)*)(%printf_t* nonnull %lookup_fmtstr_map, i32 40, %printf_t* inttoptr (i64 140695077246944 to %printf_t*))
  %17 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i64 0, i32 0
  store i64 0, i64* %17, align 8
  %18 = bitcast i32* %"struct Foo.m" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %18)
  %probe_read10 = call i64 inttoptr (i64 4 to i64 (i32*, i32, [4 x i8]*)*)(i32* nonnull %"struct Foo.m", i32 4, [4 x i8]* nonnull %"lookup_$foo_map")
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %18)
  %19 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i64 0, i32 1
  store i64 0, i64* %19, align 8
  %20 = bitcast i32* %"struct Foo.m16" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %20)
  %probe_read17 = call i64 inttoptr (i64 4 to i64 (i32*, i32, [4 x i8]*)*)(i32* nonnull %"struct Foo.m16", i32 4, [4 x i8]* nonnull %"lookup_$foo_map")
  %21 = load i32, i32* %"struct Foo.m16", align 4
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %20)
  %rhs_true_cond = icmp ne i32 %21, 0
  %"&&_result15.0" = zext i1 %rhs_true_cond to i64
  %22 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i64 0, i32 2
  store i64 %"&&_result15.0", i64* %22, align 8
  %23 = bitcast i32* %"struct Foo.m18" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %23)
  %probe_read19 = call i64 inttoptr (i64 4 to i64 (i32*, i32, [4 x i8]*)*)(i32* nonnull %"struct Foo.m18", i32 4, [4 x i8]* nonnull %"lookup_$foo_map")
  %24 = load i32, i32* %"struct Foo.m18", align 4
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %23)
  %lhs_true_cond20 = icmp ne i32 %24, 0
  %"||_result.0" = zext i1 %lhs_true_cond20 to i64
  %25 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i64 0, i32 3
  store i64 %"||_result.0", i64* %25, align 8
  %26 = bitcast i32* %"struct Foo.m26" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %26)
  %probe_read27 = call i64 inttoptr (i64 4 to i64 (i32*, i32, [4 x i8]*)*)(i32* nonnull %"struct Foo.m26", i32 4, [4 x i8]* nonnull %"lookup_$foo_map")
  %27 = load i32, i32* %"struct Foo.m26", align 4
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %26)
  %rhs_true_cond28 = icmp ne i32 %27, 0
  %"||_result25.0" = zext i1 %rhs_true_cond28 to i64
  %28 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i64 0, i32 4
  store i64 %"||_result25.0", i64* %28, align 8
  %pseudo29 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output30 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %printf_t*, i64)*)(i8* %0, i64 %pseudo29, i64 4294967295, %printf_t* nonnull %lookup_fmtstr_map, i64 40)
  %29 = bitcast %printf_t* %lookup_fmtstr_map to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %29)
  ret i64 0
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

attributes #0 = { nounwind }
attributes #1 = { argmemonly nounwind }
