; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>
%printf_t = type { i64, i64 }

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64 %0, i64 %1) #0

define i64 @"kprobe:f"(i8* %0) section "s_kprobe:f_1" {
entry:
  %deref2 = alloca i32, align 4
  %deref = alloca i64, align 8
  %helper_error_t = alloca %helper_error_t, align 8
  %lookup_fmtstr_key = alloca i32, align 4
  %"$pp" = alloca i64, align 8
  %1 = bitcast i64* %"$pp" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %1)
  store i64 0, i64* %"$pp", align 8
  store i64 0, i64* %"$pp", align 8
  %2 = bitcast i32* %lookup_fmtstr_key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %2)
  store i32 0, i32* %lookup_fmtstr_key, align 4
  %pseudo = call i64 @llvm.bpf.pseudo(i64 1, i64 0)
  %lookup_fmtstr_map = call %printf_t* inttoptr (i64 1 to %printf_t* (i64, i32*)*)(i64 %pseudo, i32* %lookup_fmtstr_key)
  %3 = bitcast i32* %lookup_fmtstr_key to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %3)
  %4 = sext %printf_t* %lookup_fmtstr_map to i32
  %5 = icmp ne i32 %4, 0
  br i1 %5, label %helper_merge, label %helper_failure

helper_failure:                                   ; preds = %entry
  %6 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %6)
  %7 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 0
  store i64 30006, i64* %7, align 8
  %8 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 1
  store i64 0, i64* %8, align 8
  %9 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 2
  store i32 %4, i32* %9, align 4
  %10 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 3
  store i8 1, i8* %10, align 1
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo1, i64 4294967295, %helper_error_t* %helper_error_t, i64 21)
  %11 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %11)
  ret i64 0

helper_merge:                                     ; preds = %entry
  %12 = bitcast %printf_t* %lookup_fmtstr_map to i8*
  call void @llvm.memset.p0i8.i64(i8* align 1 %12, i8 0, i64 16, i1 false)
  %13 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i32 0, i32 0
  store i64 0, i64* %13, align 8
  %14 = load i64, i64* %"$pp", align 8
  %15 = bitcast i64* %deref to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %15)
  %probe_read_kernel = call i64 inttoptr (i64 113 to i64 (i64*, i32, i64)*)(i64* %deref, i32 8, i64 %14)
  %16 = load i64, i64* %deref, align 8
  %17 = bitcast i64* %deref to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %17)
  %18 = bitcast i32* %deref2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %18)
  %probe_read_kernel3 = call i64 inttoptr (i64 113 to i64 (i32*, i32, i64)*)(i32* %deref2, i32 4, i64 %16)
  %19 = load i32, i32* %deref2, align 4
  %20 = sext i32 %19 to i64
  %21 = bitcast i32* %deref2 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %21)
  %22 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i32 0, i32 1
  store i64 %20, i64* %22, align 8
  %pseudo4 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output5 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %printf_t*, i64)*)(i8* %0, i64 %pseudo4, i64 4294967295, %printf_t* %lookup_fmtstr_map, i64 16)
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
