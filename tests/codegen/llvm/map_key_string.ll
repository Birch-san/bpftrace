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
  %3 = sext %key_t* %lookup_key_map to i32
  %4 = icmp ne i32 %3, 0
  br i1 %4, label %helper_merge, label %helper_failure

helper_failure:                                   ; preds = %entry
  %5 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %5)
  %6 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 0
  store i64 30006, i64* %6
  %7 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 1
  store i64 0, i64* %7
  %8 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 2
  store i32 %3, i32* %8
  %9 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 3
  store i8 1, i8* %9
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo1, i64 4294967295, %helper_error_t* %helper_error_t, i64 21)
  %10 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %10)
  ret i64 0

helper_merge:                                     ; preds = %entry
  %11 = bitcast %key_t* %lookup_key_map to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %11, i64 0, i64 128, i1 false)
  %12 = bitcast i32* %key2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %12)
  store i32 0, i32* %key2
  %pseudo3 = call i64 @llvm.bpf.pseudo(i64 1, i64 3)
  %lookup_str_map = call [64 x i8]* inttoptr (i64 1 to [64 x i8]* (i64, i32*)*)(i64 %pseudo3, i32* %key2)
  %13 = sext [64 x i8]* %lookup_str_map to i32
  %14 = icmp ne i32 %13, 0
  br i1 %14, label %helper_merge5, label %helper_failure4

helper_failure4:                                  ; preds = %helper_merge
  %15 = bitcast %helper_error_t* %helper_error_t6 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %15)
  %16 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t6, i64 0, i32 0
  store i64 30006, i64* %16
  %17 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t6, i64 0, i32 1
  store i64 1, i64* %17
  %18 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t6, i64 0, i32 2
  store i32 %13, i32* %18
  %19 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t6, i64 0, i32 3
  store i8 1, i8* %19
  %pseudo7 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output8 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo7, i64 4294967295, %helper_error_t* %helper_error_t6, i64 21)
  %20 = bitcast %helper_error_t* %helper_error_t6 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %20)
  ret i64 0

helper_merge5:                                    ; preds = %helper_merge
  %21 = bitcast [64 x i8]* %lookup_str_map to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %21, i64 0, i64 64, i1 false)
  store [2 x i8] c"a\00", [64 x i8]* %lookup_str_map, align 8
  %22 = getelementptr %key_t, %key_t* %lookup_key_map, i32 0, i32 0
  %23 = bitcast [64 x i8]* %22 to i8*
  %24 = bitcast [64 x i8]* %lookup_str_map to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %23, i8* align 8 %24, i64 64, i1 false)
  %25 = bitcast i32* %key9 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %25)
  store i32 1, i32* %key9
  %pseudo10 = call i64 @llvm.bpf.pseudo(i64 1, i64 3)
  %lookup_str_map11 = call [64 x i8]* inttoptr (i64 1 to [64 x i8]* (i64, i32*)*)(i64 %pseudo10, i32* %key9)
  %26 = sext [64 x i8]* %lookup_str_map11 to i32
  %27 = icmp ne i32 %26, 0
  br i1 %27, label %helper_merge13, label %helper_failure12

helper_failure12:                                 ; preds = %helper_merge5
  %28 = bitcast %helper_error_t* %helper_error_t14 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %28)
  %29 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t14, i64 0, i32 0
  store i64 30006, i64* %29
  %30 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t14, i64 0, i32 1
  store i64 2, i64* %30
  %31 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t14, i64 0, i32 2
  store i32 %26, i32* %31
  %32 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t14, i64 0, i32 3
  store i8 1, i8* %32
  %pseudo15 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output16 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo15, i64 4294967295, %helper_error_t* %helper_error_t14, i64 21)
  %33 = bitcast %helper_error_t* %helper_error_t14 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %33)
  ret i64 0

helper_merge13:                                   ; preds = %helper_merge5
  %34 = bitcast [64 x i8]* %lookup_str_map11 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %34, i64 0, i64 64, i1 false)
  store [2 x i8] c"b\00", [64 x i8]* %lookup_str_map11, align 8
  %35 = getelementptr %key_t, %key_t* %lookup_key_map, i32 0, i32 1
  %36 = bitcast [64 x i8]* %35 to i8*
  %37 = bitcast [64 x i8]* %lookup_str_map11 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %36, i8* align 8 %37, i64 64, i1 false)
  %pseudo17 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %update_elem = call i64 inttoptr (i64 2 to i64 (i64, %key_t*, i64*, i64)*)(i64 %pseudo17, %key_t* %lookup_key_map, i64* %"@x_val", i64 0)
  %38 = bitcast i64* %"@x_val" to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %38)
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
