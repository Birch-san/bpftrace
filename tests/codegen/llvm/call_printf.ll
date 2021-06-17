; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>
%printf_t = type { i64, i64, i64 }

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64 %0, i64 %1) #0

define i64 @"kprobe:f"(i8* %0) section "s_kprobe:f_1" {
entry:
  %"struct Foo.l" = alloca i64, align 8
  %"struct Foo.c" = alloca i8, align 1
  %helper_error_t = alloca %helper_error_t, align 8
  %lookup_fmtstr_key = alloca i32, align 4
  %"$foo" = alloca i64, align 8
  %1 = bitcast i64* %"$foo" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %1)
  store i64 0, i64* %"$foo", align 8
  %2 = bitcast i8* %0 to i64*
  %3 = getelementptr i64, i64* %2, i64 14
  %arg0 = load volatile i64, i64* %3, align 8
  store i64 %arg0, i64* %"$foo", align 8
  %4 = bitcast i32* %lookup_fmtstr_key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %4)
  store i32 0, i32* %lookup_fmtstr_key, align 4
  %pseudo = call i64 @llvm.bpf.pseudo(i64 1, i64 0)
  %lookup_fmtstr_map = call %printf_t* inttoptr (i64 1 to %printf_t* (i64, i32*)*)(i64 %pseudo, i32* %lookup_fmtstr_key)
  %5 = bitcast i32* %lookup_fmtstr_key to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %5)
  %6 = sext %printf_t* %lookup_fmtstr_map to i32
  %7 = icmp ne i32 %6, 0
  br i1 %7, label %helper_merge, label %helper_failure

helper_failure:                                   ; preds = %entry
  %8 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %8)
  %9 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 0
  store i64 30006, i64* %9, align 8
  %10 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 1
  store i64 0, i64* %10, align 8
  %11 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 2
  store i32 %6, i32* %11, align 4
  %12 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 3
  store i8 1, i8* %12, align 1
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo1, i64 4294967295, %helper_error_t* %helper_error_t, i64 21)
  %13 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %13)
  ret i64 0

helper_merge:                                     ; preds = %entry
  %14 = bitcast %printf_t* %lookup_fmtstr_map to i8*
  call void @llvm.memset.p0i8.i64(i8* align 1 %14, i8 0, i64 24, i1 false)
  %15 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i32 0, i32 0
  store i64 0, i64* %15, align 8
  %16 = load i64, i64* %"$foo", align 8
  %17 = add i64 %16, 0
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %"struct Foo.c")
  %probe_read_kernel = call i64 inttoptr (i64 113 to i64 (i8*, i32, i64)*)(i8* %"struct Foo.c", i32 1, i64 %17)
  %18 = load i8, i8* %"struct Foo.c", align 1
  %19 = sext i8 %18 to i64
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %"struct Foo.c")
  %20 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i32 0, i32 1
  store i64 %19, i64* %20, align 8
  %21 = load i64, i64* %"$foo", align 8
  %22 = add i64 %21, 8
  %23 = bitcast i64* %"struct Foo.l" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %23)
  %probe_read_kernel2 = call i64 inttoptr (i64 113 to i64 (i64*, i32, i64)*)(i64* %"struct Foo.l", i32 8, i64 %22)
  %24 = load i64, i64* %"struct Foo.l", align 8
  %25 = bitcast i64* %"struct Foo.l" to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %25)
  %26 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i32 0, i32 2
  store i64 %24, i64* %26, align 8
  %pseudo3 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output4 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %printf_t*, i64)*)(i8* %0, i64 %pseudo3, i64 4294967295, %printf_t* %lookup_fmtstr_map, i64 24)
  ret i64 0
}

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg %0, i8* nocapture %1) #1

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg %0, i8* nocapture %1) #1

; Function Attrs: argmemonly nofree nosync nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly %0, i8 %1, i64 %2, i1 immarg %3) #2

attributes #0 = { nounwind }
attributes #1 = { argmemonly nofree nosync nounwind willreturn }
attributes #2 = { argmemonly nofree nosync nounwind willreturn writeonly }
