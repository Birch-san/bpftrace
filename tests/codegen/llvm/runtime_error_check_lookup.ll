; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64, i64) #0

define i64 @"kprobe:f"(i8*) local_unnamed_addr section "s_kprobe:f_1" {
entry:
  %helper_error_t3 = alloca %helper_error_t, align 8
  %"@_newval" = alloca i64, align 8
  %helper_error_t = alloca %helper_error_t, align 8
  %"@_key" = alloca i64, align 8
  %1 = bitcast i64* %"@_key" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %1)
  store i64 0, i64* %"@_key", align 8
  %pseudo = tail call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %lookup_elem = call i8* inttoptr (i64 1 to i8* (i64, i64*)*)(i64 %pseudo, i64* nonnull %"@_key")
  %map_lookup_cond = icmp eq i8* %lookup_elem, null
  br i1 %map_lookup_cond, label %lookup_failure, label %lookup_success

lookup_success:                                   ; preds = %entry
  %cast = bitcast i8* %lookup_elem to i64*
  %2 = load i64, i64* %cast, align 8
  %phitmp = add i64 %2, 1
  br label %lookup_merge

lookup_failure:                                   ; preds = %entry
  %3 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %3)
  %4 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 0
  store i64 30006, i64* %4, align 8
  %5 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 1
  store i64 0, i64* %5, align 8
  %6 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 2
  store i32 0, i32* %6, align 8
  %7 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 3
  store i8 0, i8* %7, align 4
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo1, i64 4294967295, %helper_error_t* nonnull %helper_error_t, i64 21)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %3)
  br label %lookup_merge

lookup_merge:                                     ; preds = %lookup_failure, %lookup_success
  %lookup_elem_val.0 = phi i64 [ %phitmp, %lookup_success ], [ 1, %lookup_failure ]
  %8 = bitcast i64* %"@_newval" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %8)
  store i64 %lookup_elem_val.0, i64* %"@_newval", align 8
  %pseudo2 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %update_elem = call i64 inttoptr (i64 2 to i64 (i64, i64*, i64*, i64)*)(i64 %pseudo2, i64* nonnull %"@_key", i64* nonnull %"@_newval", i64 0)
  %9 = trunc i64 %update_elem to i32
  %10 = icmp sgt i32 %9, -1
  br i1 %10, label %helper_merge, label %helper_failure

helper_failure:                                   ; preds = %lookup_merge
  %11 = bitcast %helper_error_t* %helper_error_t3 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %11)
  %12 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t3, i64 0, i32 0
  store i64 30006, i64* %12, align 8
  %13 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t3, i64 0, i32 1
  store i64 1, i64* %13, align 8
  %14 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t3, i64 0, i32 2
  store i32 %9, i32* %14, align 8
  %15 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t3, i64 0, i32 3
  store i8 0, i8* %15, align 4
  %pseudo4 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output5 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo4, i64 4294967295, %helper_error_t* nonnull %helper_error_t3, i64 21)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %11)
  br label %helper_merge

helper_merge:                                     ; preds = %helper_failure, %lookup_merge
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %1)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %8)
  ret i64 0
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

attributes #0 = { nounwind }
attributes #1 = { argmemonly nounwind }
