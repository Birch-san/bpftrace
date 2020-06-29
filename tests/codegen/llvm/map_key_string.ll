; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>
%key_t = type { [64 x i8], [64 x i8] }

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64, i64) #0

define i64 @"kprobe:f"(i8*) local_unnamed_addr section "s_kprobe:f_1" {
entry:
  %helper_error_t15 = alloca %helper_error_t, align 8
  %key10 = alloca i32, align 4
  %helper_error_t6 = alloca %helper_error_t, align 8
  %key2 = alloca i32, align 4
  %helper_error_t = alloca %helper_error_t, align 8
  %key = alloca i32, align 4
  %"@x_val" = alloca i64, align 8
  %1 = bitcast i64* %"@x_val" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %1)
  store i64 44, i64* %"@x_val", align 8
  %2 = bitcast i32* %key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %2)
  store i32 0, i32* %key, align 4
  %pseudo = tail call i64 @llvm.bpf.pseudo(i64 1, i64 4)
  %lookup_key_map = call %key_t* inttoptr (i64 1 to %key_t* (i64, i32*)*)(i64 %pseudo, i32* nonnull %key)
  %3 = icmp eq %key_t* %lookup_key_map, null
  br i1 %3, label %helper_failure, label %helper_merge

helper_failure:                                   ; preds = %entry
  %4 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %4)
  %5 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 0
  store i64 30006, i64* %5, align 8
  %6 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 1
  store i64 0, i64* %6, align 8
  %7 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 2
  store i32 0, i32* %7, align 8
  %8 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 3
  store i8 1, i8* %8, align 4
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo1, i64 4294967295, %helper_error_t* nonnull %helper_error_t, i64 21)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %4)
  ret i64 0

helper_merge:                                     ; preds = %entry
  %probe_read = call i64 inttoptr (i64 4 to i64 (%key_t*, i32, %key_t*)*)(%key_t* nonnull %lookup_key_map, i32 128, %key_t* inttoptr (i64 38428624 to %key_t*))
  %9 = bitcast i32* %key2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %9)
  store i32 0, i32* %key2, align 4
  %pseudo3 = call i64 @llvm.bpf.pseudo(i64 1, i64 3)
  %lookup_str_map = call [64 x i8]* inttoptr (i64 1 to [64 x i8]* (i64, i32*)*)(i64 %pseudo3, i32* nonnull %key2)
  %10 = icmp eq [64 x i8]* %lookup_str_map, null
  br i1 %10, label %helper_failure4, label %helper_merge5

helper_failure4:                                  ; preds = %helper_merge
  %11 = bitcast %helper_error_t* %helper_error_t6 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %11)
  %12 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t6, i64 0, i32 0
  store i64 30006, i64* %12, align 8
  %13 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t6, i64 0, i32 1
  store i64 1, i64* %13, align 8
  %14 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t6, i64 0, i32 2
  store i32 0, i32* %14, align 8
  %15 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t6, i64 0, i32 3
  store i8 1, i8* %15, align 4
  %pseudo7 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output8 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo7, i64 4294967295, %helper_error_t* nonnull %helper_error_t6, i64 21)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %11)
  ret i64 0

helper_merge5:                                    ; preds = %helper_merge
  %probe_read9 = call i64 inttoptr (i64 4 to i64 ([64 x i8]*, i32, [64 x i8]*)*)([64 x i8]* nonnull %lookup_str_map, i32 64, [64 x i8]* inttoptr (i64 38428624 to [64 x i8]*))
  %probe_read_str = call i64 inttoptr (i64 45 to i64 ([64 x i8]*, i32, [1 x i8]*)*)([64 x i8]* nonnull %lookup_str_map, i32 1, [1 x i8]* inttoptr (i64 140695077335712 to [1 x i8]*))
  %16 = getelementptr %key_t, %key_t* %lookup_key_map, i64 0, i32 0, i64 0
  %17 = getelementptr inbounds [64 x i8], [64 x i8]* %lookup_str_map, i64 0, i64 0
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %16, i8* nonnull %17, i64 64, i32 1, i1 false)
  %18 = bitcast i32* %key10 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %18)
  store i32 1, i32* %key10, align 4
  %pseudo11 = call i64 @llvm.bpf.pseudo(i64 1, i64 3)
  %lookup_str_map12 = call [64 x i8]* inttoptr (i64 1 to [64 x i8]* (i64, i32*)*)(i64 %pseudo11, i32* nonnull %key10)
  %19 = icmp eq [64 x i8]* %lookup_str_map12, null
  br i1 %19, label %helper_failure13, label %helper_merge14

helper_failure13:                                 ; preds = %helper_merge5
  %20 = bitcast %helper_error_t* %helper_error_t15 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %20)
  %21 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t15, i64 0, i32 0
  store i64 30006, i64* %21, align 8
  %22 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t15, i64 0, i32 1
  store i64 2, i64* %22, align 8
  %23 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t15, i64 0, i32 2
  store i32 0, i32* %23, align 8
  %24 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t15, i64 0, i32 3
  store i8 1, i8* %24, align 4
  %pseudo16 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output17 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo16, i64 4294967295, %helper_error_t* nonnull %helper_error_t15, i64 21)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %20)
  ret i64 0

helper_merge14:                                   ; preds = %helper_merge5
  %probe_read18 = call i64 inttoptr (i64 4 to i64 ([64 x i8]*, i32, [64 x i8]*)*)([64 x i8]* nonnull %lookup_str_map12, i32 64, [64 x i8]* inttoptr (i64 38428624 to [64 x i8]*))
  %probe_read_str19 = call i64 inttoptr (i64 45 to i64 ([64 x i8]*, i32, [1 x i8]*)*)([64 x i8]* nonnull %lookup_str_map12, i32 1, [1 x i8]* inttoptr (i64 37983792 to [1 x i8]*))
  %25 = getelementptr %key_t, %key_t* %lookup_key_map, i64 0, i32 1, i64 0
  %26 = getelementptr inbounds [64 x i8], [64 x i8]* %lookup_str_map12, i64 0, i64 0
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %25, i8* nonnull %26, i64 64, i32 1, i1 false)
  %pseudo20 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %update_elem = call i64 inttoptr (i64 2 to i64 (i64, %key_t*, i64*, i64)*)(i64 %pseudo20, %key_t* nonnull %lookup_key_map, i64* nonnull %"@x_val", i64 0)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %1)
  ret i64 0
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i32, i1) #1

attributes #0 = { nounwind }
attributes #1 = { argmemonly nounwind }
