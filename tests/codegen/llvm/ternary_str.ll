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
  %2 = sext [64 x i8]* %lookup_str_map to i32
  %3 = icmp ne i32 %2, 0
  br i1 %3, label %helper_merge, label %helper_failure

left:                                             ; preds = %helper_merge
  %4 = bitcast i32* %key2 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %4)
  store i32 0, i32* %key2
  %pseudo3 = call i64 @llvm.bpf.pseudo(i64 1, i64 3)
  %lookup_str_map4 = call [64 x i8]* inttoptr (i64 1 to [64 x i8]* (i64, i32*)*)(i64 %pseudo3, i32* %key2)
  %5 = sext [64 x i8]* %lookup_str_map4 to i32
  %6 = icmp ne i32 %5, 0
  br i1 %6, label %helper_merge6, label %helper_failure5

right:                                            ; preds = %helper_merge
  %7 = bitcast i32* %key10 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %7)
  store i32 1, i32* %key10
  %pseudo11 = call i64 @llvm.bpf.pseudo(i64 1, i64 3)
  %lookup_str_map12 = call [64 x i8]* inttoptr (i64 1 to [64 x i8]* (i64, i32*)*)(i64 %pseudo11, i32* %key10)
  %8 = sext [64 x i8]* %lookup_str_map12 to i32
  %9 = icmp ne i32 %8, 0
  br i1 %9, label %helper_merge14, label %helper_failure13

done:                                             ; preds = %helper_merge14, %helper_merge6
  %10 = bitcast i64* %"@x_key" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %10)
  store i64 0, i64* %"@x_key"
  %pseudo18 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %update_elem = call i64 inttoptr (i64 2 to i64 (i64, i64*, [64 x i8]*, i64)*)(i64 %pseudo18, i64* %"@x_key", [64 x i8]* %lookup_str_map, i64 0)
  %11 = bitcast i64* %"@x_key" to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %11)
  ret i64 0

helper_failure:                                   ; preds = %entry
  %12 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %12)
  %13 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 0
  store i64 30006, i64* %13
  %14 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 1
  store i64 0, i64* %14
  %15 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 2
  store i32 %2, i32* %15
  %16 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 3
  store i8 1, i8* %16
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo1, i64 4294967295, %helper_error_t* %helper_error_t, i64 21)
  %17 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %17)
  ret i64 0

helper_merge:                                     ; preds = %entry
  %18 = bitcast [64 x i8]* %lookup_str_map to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %18, i64 0, i64 64, i1 false)
  %get_pid_tgid = call i64 inttoptr (i64 14 to i64 ()*)()
  %19 = lshr i64 %get_pid_tgid, 32
  %20 = icmp ult i64 %19, 10000
  %21 = zext i1 %20 to i64
  %true_cond = icmp ne i64 %21, 0
  br i1 %true_cond, label %left, label %right

helper_failure5:                                  ; preds = %left
  %22 = bitcast %helper_error_t* %helper_error_t7 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %22)
  %23 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t7, i64 0, i32 0
  store i64 30006, i64* %23
  %24 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t7, i64 0, i32 1
  store i64 1, i64* %24
  %25 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t7, i64 0, i32 2
  store i32 %5, i32* %25
  %26 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t7, i64 0, i32 3
  store i8 1, i8* %26
  %pseudo8 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output9 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo8, i64 4294967295, %helper_error_t* %helper_error_t7, i64 21)
  %27 = bitcast %helper_error_t* %helper_error_t7 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %27)
  ret i64 0

helper_merge6:                                    ; preds = %left
  %28 = bitcast [64 x i8]* %lookup_str_map4 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %28, i64 0, i64 64, i1 false)
  store [3 x i8] c"lo\00", [64 x i8]* %lookup_str_map4, align 8
  %29 = bitcast [64 x i8]* %lookup_str_map to i8*
  %30 = bitcast [64 x i8]* %lookup_str_map4 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %29, i8* align 8 %30, i64 64, i1 false)
  br label %done

helper_failure13:                                 ; preds = %right
  %31 = bitcast %helper_error_t* %helper_error_t15 to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %31)
  %32 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t15, i64 0, i32 0
  store i64 30006, i64* %32
  %33 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t15, i64 0, i32 1
  store i64 2, i64* %33
  %34 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t15, i64 0, i32 2
  store i32 %8, i32* %34
  %35 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t15, i64 0, i32 3
  store i8 1, i8* %35
  %pseudo16 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %perf_event_output17 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo16, i64 4294967295, %helper_error_t* %helper_error_t15, i64 21)
  %36 = bitcast %helper_error_t* %helper_error_t15 to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %36)
  ret i64 0

helper_merge14:                                   ; preds = %right
  %37 = bitcast [64 x i8]* %lookup_str_map12 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %37, i64 0, i64 64, i1 false)
  store [3 x i8] c"hi\00", [64 x i8]* %lookup_str_map12, align 8
  %38 = bitcast [64 x i8]* %lookup_str_map to i8*
  %39 = bitcast [64 x i8]* %lookup_str_map12 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %38, i8* align 8 %39, i64 64, i1 false)
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
