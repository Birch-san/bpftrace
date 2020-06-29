; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>
%buffer_64_t = type { i64, [64 x i8] }

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64, i64) #0

define i64 @"kprobe:f"(i8*) local_unnamed_addr section "s_kprobe:f_1" {
entry:
  %"@x_key" = alloca i64, align 8
  %helper_error_t = alloca %helper_error_t, align 8
  %key = alloca i32, align 4
  %1 = getelementptr i8, i8* %0, i64 104
  %2 = bitcast i8* %1 to i64*
  %arg1 = load volatile i64, i64* %2, align 8
  %3 = icmp ult i64 %arg1, 64
  %length.select = select i1 %3, i64 %arg1, i64 64
  %4 = bitcast i32* %key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %4)
  store i32 0, i32* %key, align 4
  %pseudo = tail call i64 @llvm.bpf.pseudo(i64 1, i64 3)
  %lookup_buf_map = call %buffer_64_t* inttoptr (i64 1 to %buffer_64_t* (i64, i32*)*)(i64 %pseudo, i32* nonnull %key)
  %5 = icmp eq %buffer_64_t* %lookup_buf_map, null
  br i1 %5, label %helper_failure, label %helper_merge

helper_failure:                                   ; preds = %entry
  %6 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %6)
  %7 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 0
  store i64 30006, i64* %7, align 8
  %8 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 1
  store i64 0, i64* %8, align 8
  %9 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 2
  store i32 0, i32* %9, align 8
  %10 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 3
  store i8 1, i8* %10, align 4
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* nonnull %0, i64 %pseudo1, i64 4294967295, %helper_error_t* nonnull %helper_error_t, i64 21)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %6)
  ret i64 0

helper_merge:                                     ; preds = %entry
  %probe_read = call i64 inttoptr (i64 4 to i64 (%buffer_64_t*, i32, %buffer_64_t*)*)(%buffer_64_t* nonnull %lookup_buf_map, i32 72, %buffer_64_t* inttoptr (i64 37258736 to %buffer_64_t*))
  %11 = getelementptr %buffer_64_t, %buffer_64_t* %lookup_buf_map, i64 0, i32 0
  store i64 %length.select, i64* %11, align 8
  %12 = getelementptr %buffer_64_t, %buffer_64_t* %lookup_buf_map, i64 0, i32 1
  %13 = getelementptr inbounds [64 x i8], [64 x i8]* %12, i64 0, i64 0
  call void @llvm.memset.p0i8.i64(i8* %13, i64 0, i64 64, i32 1, i1 false)
  %14 = getelementptr i8, i8* %0, i64 112
  %15 = bitcast i8* %14 to i64*
  %arg0 = load volatile i64, i64* %15, align 8
  %probe_read2 = call i64 inttoptr (i64 4 to i64 ([64 x i8]*, i32, i64)*)([64 x i8]* %12, i64 %length.select, i64 %arg0)
  %16 = bitcast i64* %"@x_key" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %16)
  store i64 0, i64* %"@x_key", align 8
  %pseudo3 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %update_elem = call i64 inttoptr (i64 2 to i64 (i64, i64*, %buffer_64_t*, i64)*)(i64 %pseudo3, i64* nonnull %"@x_key", %buffer_64_t* nonnull %lookup_buf_map, i64 0)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %16)
  ret i64 0
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i32, i1) #1

attributes #0 = { nounwind }
attributes #1 = { argmemonly nounwind }
