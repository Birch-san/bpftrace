; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>
%key_t = type { [64 x i8], [64 x i8] }

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64, i64) #0

define i64 @"kprobe:f"(i8*) section "s_kprobe:f_1" {
entry:
  %helper_error_t14 = alloca %helper_error_t
  %key9 = alloca i32
  %helper_error_t6 = alloca %helper_error_t
  %key2 = alloca i32
  %helper_error_t = alloca %helper_error_t
  %key = alloca i32
  %"@x_val" = alloca i64
  %1 = bitcast i64* %"@x_val" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %1)
  store i64 44, i64* %"@x_val"
  %2 = bitcast i32* %key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %2)
  store i32 0, i32* %key
  %pseudo = call i64 @llvm.bpf.pseudo(i64 1, i64 4)
  %lookup_key_map = call %key_t* inttoptr (i64 1 to %key_t* (i64, i32*)*)(i64 %pseudo, i32* %key)
  %3 = bitcast i32* %key to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %3)
  %4 = sext %key_t* %lookup_key_map to i32
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
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo1, i64 4294967295, %helper_error_t* %helper_error_t, i64 21)
  %11 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %11)
  ret i64 0

helper_merge:                                     ; preds = %entry
  %12 = bitcast %key_t* %lookup_key_map to i8*
  call void @llvm.memset.p0i8.i64(i8* align 1 %12, i8 0, i64 128, i1 false)
  %13 = bitcast i32* %key2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %13)
  store i32 0, i32* %key2
  %pseudo3 = call i64 @llvm.bpf.pseudo(i64 1, i64 3)
  %lookup_str_map = call [64 x i8]* inttoptr (i64 1 to [64 x i8]* (i64, i32*)*)(i64 %pseudo3, i32* %key2)
  %14 = bitcast i32* %key2 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %14)
  %15 = sext [64 x i8]* %lookup_str_map to i32
  %16 = icmp ne i32 %15, 0
  br i1 %16, label %helper_merge5, label %helper_failure4

helper_failure4:                                  ; preds = %helper_merge
  %17 = bitcast %helper_error_t* %helper_error_t6 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %17)
  %18 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t6, i64 0, i32 0
  store i64 30006, i64* %18
  %19 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t6, i64 0, i32 1
  store i64 1, i64* %19
  %20 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t6, i64 0, i32 2
  store i32 %15, i32* %20
  %21 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t6, i64 0, i32 3
  store i8 1, i8* %21
  %pseudo7 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output8 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo7, i64 4294967295, %helper_error_t* %helper_error_t6, i64 21)
  %22 = bitcast %helper_error_t* %helper_error_t6 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %22)
  ret i64 0

helper_merge5:                                    ; preds = %helper_merge
  %23 = bitcast [64 x i8]* %lookup_str_map to i8*
  call void @llvm.memset.p0i8.i64(i8* align 1 %23, i8 0, i64 64, i1 false)
  store [2 x i8] c"a\00", [64 x i8]* %lookup_str_map
  %24 = getelementptr %key_t, %key_t* %lookup_key_map, i32 0, i32 0
  %25 = bitcast [64 x i8]* %24 to i8*
  %26 = bitcast [64 x i8]* %lookup_str_map to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %25, i8* align 1 %26, i64 64, i1 false)
  %27 = bitcast [64 x i8]* %lookup_str_map to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %27)
  %28 = bitcast i32* %key9 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %28)
  store i32 1, i32* %key9
  %pseudo10 = call i64 @llvm.bpf.pseudo(i64 1, i64 3)
  %lookup_str_map11 = call [64 x i8]* inttoptr (i64 1 to [64 x i8]* (i64, i32*)*)(i64 %pseudo10, i32* %key9)
  %29 = bitcast i32* %key9 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %29)
  %30 = sext [64 x i8]* %lookup_str_map11 to i32
  %31 = icmp ne i32 %30, 0
  br i1 %31, label %helper_merge13, label %helper_failure12

helper_failure12:                                 ; preds = %helper_merge5
  %32 = bitcast %helper_error_t* %helper_error_t14 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %32)
  %33 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t14, i64 0, i32 0
  store i64 30006, i64* %33
  %34 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t14, i64 0, i32 1
  store i64 2, i64* %34
  %35 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t14, i64 0, i32 2
  store i32 %30, i32* %35
  %36 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t14, i64 0, i32 3
  store i8 1, i8* %36
  %pseudo15 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output16 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo15, i64 4294967295, %helper_error_t* %helper_error_t14, i64 21)
  %37 = bitcast %helper_error_t* %helper_error_t14 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %37)
  ret i64 0

helper_merge13:                                   ; preds = %helper_merge5
  %38 = bitcast [64 x i8]* %lookup_str_map11 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 1 %38, i8 0, i64 64, i1 false)
  store [2 x i8] c"b\00", [64 x i8]* %lookup_str_map11
  %39 = getelementptr %key_t, %key_t* %lookup_key_map, i32 0, i32 1
  %40 = bitcast [64 x i8]* %39 to i8*
  %41 = bitcast [64 x i8]* %lookup_str_map11 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %40, i8* align 1 %41, i64 64, i1 false)
  %42 = bitcast [64 x i8]* %lookup_str_map11 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %42)
  %pseudo17 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %update_elem = call i64 inttoptr (i64 2 to i64 (i64, %key_t*, i64*, i64)*)(i64 %pseudo17, %key_t* %lookup_key_map, i64* %"@x_val", i64 0)
  %43 = bitcast i64* %"@x_val" to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %43)
  ret i64 0
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i1) #1

attributes #0 = { nounwind }
attributes #1 = { argmemonly nounwind }
