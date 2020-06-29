; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64, i64) #0

define i64 @"kprobe:f"(i8*) local_unnamed_addr section "s_kprobe:f_1" {
entry:
  %"@y_key" = alloca i64, align 8
  %lookup_elem_val = alloca [64 x i8], align 1
  %"@x_key3" = alloca i64, align 8
  %"@x_key" = alloca i64, align 8
  %helper_error_t = alloca %helper_error_t, align 8
  %key = alloca i32, align 4
  %1 = bitcast i32* %key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %1)
  store i32 0, i32* %key, align 4
  %pseudo = tail call i64 @llvm.bpf.pseudo(i64 1, i64 4)
  %lookup_str_map = call [64 x i8]* inttoptr (i64 1 to [64 x i8]* (i64, i32*)*)(i64 %pseudo, i32* nonnull %key)
  %2 = icmp eq [64 x i8]* %lookup_str_map, null
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
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 3)
  %perf_event_output = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo1, i64 4294967295, %helper_error_t* nonnull %helper_error_t, i64 21)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %3)
  ret i64 0

helper_merge:                                     ; preds = %entry
  %probe_read = call i64 inttoptr (i64 4 to i64 ([64 x i8]*, i32, [64 x i8]*)*)([64 x i8]* nonnull %lookup_str_map, i32 64, [64 x i8]* inttoptr (i64 38254368 to [64 x i8]*))
  %probe_read_str = call i64 inttoptr (i64 45 to i64 ([64 x i8]*, i32, [4 x i8]*)*)([64 x i8]* nonnull %lookup_str_map, i32 4, [4 x i8]* inttoptr (i64 140695077699872 to [4 x i8]*))
  %8 = bitcast i64* %"@x_key" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %8)
  store i64 0, i64* %"@x_key", align 8
  %pseudo2 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %update_elem = call i64 inttoptr (i64 2 to i64 (i64, i64*, [64 x i8]*, i64)*)(i64 %pseudo2, i64* nonnull %"@x_key", [64 x i8]* nonnull %lookup_str_map, i64 0)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %8)
  %9 = bitcast i64* %"@x_key3" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %9)
  store i64 0, i64* %"@x_key3", align 8
  %pseudo4 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %lookup_elem = call i8* inttoptr (i64 1 to i8* (i64, i64*)*)(i64 %pseudo4, i64* nonnull %"@x_key3")
  %10 = getelementptr inbounds [64 x i8], [64 x i8]* %lookup_elem_val, i64 0, i64 0
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %10)
  %map_lookup_cond = icmp eq i8* %lookup_elem, null
  br i1 %map_lookup_cond, label %lookup_failure, label %lookup_success

lookup_success:                                   ; preds = %helper_merge
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull %10, i8* nonnull %lookup_elem, i64 64, i32 1, i1 false)
  br label %lookup_merge

lookup_failure:                                   ; preds = %helper_merge
  call void @llvm.memset.p0i8.i64(i8* nonnull %10, i8 0, i64 64, i32 1, i1 false)
  br label %lookup_merge

lookup_merge:                                     ; preds = %lookup_failure, %lookup_success
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %9)
  %11 = bitcast i64* %"@y_key" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %11)
  store i64 0, i64* %"@y_key", align 8
  %pseudo5 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %update_elem6 = call i64 inttoptr (i64 2 to i64 (i64, i64*, [64 x i8]*, i64)*)(i64 %pseudo5, i64* nonnull %"@y_key", [64 x i8]* nonnull %lookup_elem_val, i64 0)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %11)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %10)
  ret i64 0
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i32, i1) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i32, i1) #1

attributes #0 = { nounwind }
attributes #1 = { argmemonly nounwind }
