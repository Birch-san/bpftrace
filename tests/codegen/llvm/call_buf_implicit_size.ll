; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>
%buffer_16_t = type { i64, [16 x i8] }

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64, i64) #0

define i64 @"kprobe:f"(i8*) local_unnamed_addr section "s_kprobe:f_1" {
entry:
  %"@x_key" = alloca i64, align 8
  %helper_error_t = alloca %helper_error_t, align 8
  %key = alloca i32, align 4
  %1 = bitcast i32* %key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %1)
  store i32 0, i32* %key, align 4
  %pseudo = tail call i64 @llvm.bpf.pseudo(i64 1, i64 3)
  %lookup_buf_map = call %buffer_16_t* inttoptr (i64 1 to %buffer_16_t* (i64, i32*)*)(i64 %pseudo, i32* nonnull %key)
  %2 = icmp eq %buffer_16_t* %lookup_buf_map, null
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
  %probe_read = call i64 inttoptr (i64 4 to i64 (%buffer_16_t*, i32, %buffer_16_t*)*)(%buffer_16_t* nonnull %lookup_buf_map, i32 24, %buffer_16_t* inttoptr (i64 37230096 to %buffer_16_t*))
  %8 = getelementptr %buffer_16_t, %buffer_16_t* %lookup_buf_map, i64 0, i32 0
  store i64 16, i64* %8, align 8
  %9 = getelementptr %buffer_16_t, %buffer_16_t* %lookup_buf_map, i64 0, i32 1
  %10 = getelementptr inbounds [16 x i8], [16 x i8]* %9, i64 0, i64 0
  call void @llvm.memset.p0i8.i64(i8* %10, i64 0, i64 16, i32 1, i1 false)
  %probe_read2 = call i64 inttoptr (i64 4 to i64 ([16 x i8]*, i32, i64)*)([16 x i8]* %9, i64 16, i64 0)
  %11 = bitcast i64* %"@x_key" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %11)
  store i64 0, i64* %"@x_key", align 8
  %pseudo3 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %update_elem = call i64 inttoptr (i64 2 to i64 (i64, i64*, %buffer_16_t*, i64)*)(i64 %pseudo3, i64* nonnull %"@x_key", %buffer_16_t* nonnull %lookup_buf_map, i64 0)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %11)
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
