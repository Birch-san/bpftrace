; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>
%printf_t = type { i64, i64, i64 }

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64, i64) #0

define i64 @"kprobe:f"(i8*) section "s_kprobe:f_1" {
entry:
  %"struct Foo.l" = alloca i64
  %"struct Foo.c" = alloca i8
  %helper_error_t = alloca %helper_error_t
  %key = alloca i32
  %"$foo" = alloca i64
  %1 = bitcast i64* %"$foo" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %1)
  store i64 0, i64* %"$foo"
  %2 = bitcast i64* %"$foo" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %2)
  store i64 0, i64* %"$foo"
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
  call void @llvm.memset.p0i8.i64(i8* align 8 %12, i64 0, i64 24, i1 false)
  %13 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i32 0, i32 0
  store i64 0, i64* %13
  %14 = load i64, i64* %"$foo"
  %15 = add i64 %14, 0
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %"struct Foo.c")
  %probe_read = call i64 inttoptr (i64 4 to i64 (i8*, i32, i64)*)(i8* %"struct Foo.c", i32 1, i64 %15)
  %16 = load i8, i8* %"struct Foo.c"
  %17 = sext i8 %16 to i64
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %"struct Foo.c")
  %18 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i32 0, i32 1
  store i64 %17, i64* %18
  %19 = load i64, i64* %"$foo"
  %20 = add i64 %19, 8
  %21 = bitcast i64* %"struct Foo.l" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %21)
  %probe_read2 = call i64 inttoptr (i64 4 to i64 (i64*, i32, i64)*)(i64* %"struct Foo.l", i32 8, i64 %20)
  %22 = load i64, i64* %"struct Foo.l"
  %23 = bitcast i64* %"struct Foo.l" to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %23)
  %24 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i32 0, i32 2
  store i64 %22, i64* %24
  %pseudo3 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output4 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %printf_t*, i64)*)(i8* %0, i64 %pseudo3, i64 4294967295, %printf_t* %lookup_fmtstr_map, i64 24)
  %25 = bitcast %printf_t* %lookup_fmtstr_map to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %25)
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
