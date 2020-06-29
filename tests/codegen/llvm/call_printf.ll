; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>
%printf_t = type <{ i64, i64, i64 }>

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64, i64) #0

define i64 @"kprobe:f"(i8*) local_unnamed_addr section "s_kprobe:f_1" {
entry:
  %"struct Foo.l" = alloca i64, align 8
  %"struct Foo.c" = alloca i8, align 1
  %helper_error_t = alloca %helper_error_t, align 8
  %key = alloca i32, align 4
  %1 = bitcast i32* %key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %1)
  store i32 0, i32* %key, align 4
  %pseudo = tail call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %lookup_fmtstr_map = call %printf_t* inttoptr (i64 1 to %printf_t* (i64, i32*)*)(i64 %pseudo, i32* nonnull %key)
  %2 = icmp eq %printf_t* %lookup_fmtstr_map, null
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
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo1, i64 4294967295, %helper_error_t* nonnull %helper_error_t, i64 21)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %3)
  ret i64 0

helper_merge:                                     ; preds = %entry
  %probe_read = call i64 inttoptr (i64 4 to i64 (%printf_t*, i32, %printf_t*)*)(%printf_t* nonnull %lookup_fmtstr_map, i32 24, %printf_t* inttoptr (i64 140695075651984 to %printf_t*))
  %8 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i64 0, i32 0
  store i64 0, i64* %8, align 8
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %"struct Foo.c")
  %probe_read2 = call i64 inttoptr (i64 4 to i64 (i8*, i32, i64)*)(i8* nonnull %"struct Foo.c", i32 1, i64 0)
  %9 = load i8, i8* %"struct Foo.c", align 1
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %"struct Foo.c")
  %10 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i64 0, i32 1
  store i8 %9, i64* %10, align 1
  %11 = bitcast i64* %"struct Foo.l" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %11)
  %probe_read3 = call i64 inttoptr (i64 4 to i64 (i64*, i32, i64)*)(i64* nonnull %"struct Foo.l", i32 8, i64 8)
  %12 = load i64, i64* %"struct Foo.l", align 8
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %11)
  %13 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i64 0, i32 2
  store i64 %12, i64* %13, align 8
  %pseudo4 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output5 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %printf_t*, i64)*)(i8* %0, i64 %pseudo4, i64 4294967295, %printf_t* nonnull %lookup_fmtstr_map, i64 24)
  %14 = bitcast %printf_t* %lookup_fmtstr_map to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %14)
  ret i64 0
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

attributes #0 = { nounwind }
attributes #1 = { argmemonly nounwind }
