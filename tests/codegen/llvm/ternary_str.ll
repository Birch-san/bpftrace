; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64, i64) #0

define i64 @"kprobe:f"(i8*) section "s_kprobe:f_1" {
entry:
  %"@x_key" = alloca i64
  %helper_error_t15 = alloca %helper_error_t
  %key10 = alloca i32
  %helper_error_t7 = alloca %helper_error_t
  %key2 = alloca i32
  %helper_error_t = alloca %helper_error_t
  %key = alloca i32
  %1 = bitcast i32* %key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %1)
  store i32 2, i32* %key
  %pseudo = call i64 @llvm.bpf.pseudo(i64 1, i64 3)
  %lookup_str_map = call [64 x i8]* inttoptr (i64 1 to [64 x i8]* (i64, i32*)*)(i64 %pseudo, i32* %key)
  %2 = bitcast i32* %key to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %2)
  %3 = sext [64 x i8]* %lookup_str_map to i32
  %4 = icmp ne i32 %3, 0
  br i1 %4, label %helper_merge, label %helper_failure

left:                                             ; preds = %helper_merge
  %5 = bitcast i32* %key2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %5)
  store i32 0, i32* %key2
  %pseudo3 = call i64 @llvm.bpf.pseudo(i64 1, i64 3)
  %lookup_str_map4 = call [64 x i8]* inttoptr (i64 1 to [64 x i8]* (i64, i32*)*)(i64 %pseudo3, i32* %key2)
  %6 = bitcast i32* %key2 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %6)
  %7 = sext [64 x i8]* %lookup_str_map4 to i32
  %8 = icmp ne i32 %7, 0
  br i1 %8, label %helper_merge6, label %helper_failure5

right:                                            ; preds = %helper_merge
  %9 = bitcast i32* %key10 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %9)
  store i32 1, i32* %key10
  %pseudo11 = call i64 @llvm.bpf.pseudo(i64 1, i64 3)
  %lookup_str_map12 = call [64 x i8]* inttoptr (i64 1 to [64 x i8]* (i64, i32*)*)(i64 %pseudo11, i32* %key10)
  %10 = bitcast i32* %key10 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %10)
  %11 = sext [64 x i8]* %lookup_str_map12 to i32
  %12 = icmp ne i32 %11, 0
  br i1 %12, label %helper_merge14, label %helper_failure13

done:                                             ; preds = %helper_merge14, %helper_merge6
  %13 = bitcast [64 x i8]* %lookup_str_map12 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %13)
  %14 = bitcast [64 x i8]* %lookup_str_map4 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %14)
  %15 = bitcast i64* %"@x_key" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %15)
  store i64 0, i64* %"@x_key"
  %pseudo18 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %update_elem = call i64 inttoptr (i64 2 to i64 (i64, i64*, [64 x i8]*, i64)*)(i64 %pseudo18, i64* %"@x_key", [64 x i8]* %lookup_str_map, i64 0)
  %16 = bitcast i64* %"@x_key" to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %16)
  %17 = bitcast [64 x i8]* %lookup_str_map to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %17)
  ret i64 0

helper_failure:                                   ; preds = %entry
  %18 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %18)
  %19 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 0
  store i64 30006, i64* %19
  %20 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 1
  store i64 0, i64* %20
  %21 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 2
  store i32 %3, i32* %21
  %22 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 3
  store i8 1, i8* %22
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo1, i64 4294967295, %helper_error_t* %helper_error_t, i64 21)
  %23 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %23)
  ret i64 0

helper_merge:                                     ; preds = %entry
  %24 = bitcast [64 x i8]* %lookup_str_map to i8*
  call void @llvm.memset.p0i8.i64(i8* align 1 %24, i8 0, i64 64, i1 false)
  %get_pid_tgid = call i64 inttoptr (i64 14 to i64 ()*)()
  %25 = lshr i64 %get_pid_tgid, 32
  %26 = icmp ult i64 %25, 10000
  %27 = zext i1 %26 to i64
  %true_cond = icmp ne i64 %27, 0
  br i1 %true_cond, label %left, label %right

helper_failure5:                                  ; preds = %left
  %28 = bitcast %helper_error_t* %helper_error_t7 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %28)
  %29 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t7, i64 0, i32 0
  store i64 30006, i64* %29
  %30 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t7, i64 0, i32 1
  store i64 1, i64* %30
  %31 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t7, i64 0, i32 2
  store i32 %7, i32* %31
  %32 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t7, i64 0, i32 3
  store i8 1, i8* %32
  %pseudo8 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output9 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo8, i64 4294967295, %helper_error_t* %helper_error_t7, i64 21)
  %33 = bitcast %helper_error_t* %helper_error_t7 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %33)
  ret i64 0

helper_merge6:                                    ; preds = %left
  %34 = bitcast [64 x i8]* %lookup_str_map4 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 1 %34, i8 0, i64 64, i1 false)
  store [3 x i8] c"lo\00", [64 x i8]* %lookup_str_map4
  %35 = bitcast [64 x i8]* %lookup_str_map to i8*
  %36 = bitcast [64 x i8]* %lookup_str_map4 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %35, i8* align 1 %36, i64 64, i1 false)
  br label %done

helper_failure13:                                 ; preds = %right
  %37 = bitcast %helper_error_t* %helper_error_t15 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %37)
  %38 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t15, i64 0, i32 0
  store i64 30006, i64* %38
  %39 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t15, i64 0, i32 1
  store i64 2, i64* %39
  %40 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t15, i64 0, i32 2
  store i32 %11, i32* %40
  %41 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t15, i64 0, i32 3
  store i8 1, i8* %41
  %pseudo16 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output17 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo16, i64 4294967295, %helper_error_t* %helper_error_t15, i64 21)
  %42 = bitcast %helper_error_t* %helper_error_t15 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %42)
  ret i64 0

helper_merge14:                                   ; preds = %right
  %43 = bitcast [64 x i8]* %lookup_str_map12 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 1 %43, i8 0, i64 64, i1 false)
  store [3 x i8] c"hi\00", [64 x i8]* %lookup_str_map12
  %44 = bitcast [64 x i8]* %lookup_str_map to i8*
  %45 = bitcast [64 x i8]* %lookup_str_map12 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %44, i8* align 1 %45, i64 64, i1 false)
  br label %done
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
