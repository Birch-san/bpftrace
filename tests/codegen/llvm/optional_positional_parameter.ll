; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64, i64) #0

define i64 @BEGIN(i8*) local_unnamed_addr section "s_BEGIN_1" {
entry:
  %"@y_key" = alloca i64, align 8
  %str = alloca [1 x i8], align 1
  %helper_error_t = alloca %helper_error_t, align 8
  %key = alloca i32, align 4
  %"@x_key" = alloca i64, align 8
  %"@x_val" = alloca i64, align 8
  %1 = bitcast i64* %"@x_val" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %1)
  store i64 0, i64* %"@x_val", align 8
  %2 = bitcast i64* %"@x_key" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %2)
  store i64 0, i64* %"@x_key", align 8
  %pseudo = tail call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %update_elem = call i64 inttoptr (i64 2 to i64 (i64, i64*, i64*, i64)*)(i64 %pseudo, i64* nonnull %"@x_key", i64* nonnull %"@x_val", i64 0)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %2)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %1)
  %3 = bitcast i32* %key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %3)
  store i32 0, i32* %key, align 4
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 4)
  %lookup_str_map = call [64 x i8]* inttoptr (i64 1 to [64 x i8]* (i64, i32*)*)(i64 %pseudo1, i32* nonnull %key)
  %4 = icmp eq [64 x i8]* %lookup_str_map, null
  br i1 %4, label %helper_failure, label %helper_merge

helper_failure:                                   ; preds = %entry
  %5 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %5)
  %6 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 0
  store i64 30006, i64* %6, align 8
  %7 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 1
  store i64 0, i64* %7, align 8
  %8 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 2
  store i32 0, i32* %8, align 8
  %9 = getelementptr inbounds %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 3
  store i8 1, i8* %9, align 4
  %pseudo2 = call i64 @llvm.bpf.pseudo(i64 1, i64 3)
  %perf_event_output = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo2, i64 4294967295, %helper_error_t* nonnull %helper_error_t, i64 21)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %5)
  ret i64 0

helper_merge:                                     ; preds = %entry
  %10 = getelementptr inbounds [1 x i8], [1 x i8]* %str, i64 0, i64 0
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %10)
  store i8 0, i8* %10, align 1
  %probe_read = call i64 inttoptr (i64 4 to i64 ([64 x i8]*, i32, [64 x i8]*)*)([64 x i8]* nonnull %lookup_str_map, i32 64, [64 x i8]* inttoptr (i64 36504128 to [64 x i8]*))
  %probe_read_str = call i64 inttoptr (i64 45 to i64 ([64 x i8]*, i32, [1 x i8]*)*)([64 x i8]* nonnull %lookup_str_map, i64 64, [1 x i8]* nonnull %str)
  %11 = bitcast i64* %"@y_key" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* nonnull %11)
  store i64 0, i64* %"@y_key", align 8
  %pseudo3 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %update_elem4 = call i64 inttoptr (i64 2 to i64 (i64, i64*, [64 x i8]*, i64)*)(i64 %pseudo3, i64* nonnull %"@y_key", [64 x i8]* nonnull %lookup_str_map, i64 0)
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* nonnull %11)
  ret i64 0
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

attributes #0 = { nounwind }
attributes #1 = { argmemonly nounwind }
