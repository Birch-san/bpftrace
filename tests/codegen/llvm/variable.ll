; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64, i64) #0

define i64 @"kprobe:f"(i8*) section "s_kprobe:f_1" {
entry:
  %"@y_key" = alloca i64
  %"@x_key" = alloca i64
  %helper_error_t = alloca %helper_error_t
  %key = alloca i32
  %comm = alloca [16 x i8]
  %1 = bitcast [16 x i8]* %comm to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %1)
  %2 = bitcast [16 x i8]* %comm to i8*
  call void @llvm.memset.p0i8.i64(i8* align 1 %2, i8 0, i64 16, i1 false)
  %get_comm = call i64 inttoptr (i64 16 to i64 ([16 x i8]*, i64)*)([16 x i8]* %comm, i64 16)
  %3 = bitcast i32* %key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %3)
  store i32 0, i32* %key
  %pseudo = call i64 @llvm.bpf.pseudo(i64 1, i64 3)
  %"lookup_$var_map" = call [16 x i8]* inttoptr (i64 1 to [16 x i8]* (i64, i32*)*)(i64 %pseudo, i32* %key)
  %4 = sext [16 x i8]* %"lookup_$var_map" to i32
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
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 4)
  %perf_event_output = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo1, i64 4294967295, %helper_error_t* %helper_error_t, i64 21)
  %11 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %11)
  ret i64 0

helper_merge:                                     ; preds = %entry
  %12 = bitcast [16 x i8]* %"lookup_$var_map" to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %12, i64 0, i64 16, i1 false)
  %13 = bitcast [16 x i8]* %"lookup_$var_map" to i8*
  %14 = bitcast [16 x i8]* %comm to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %13, i8* align 8 %14, i64 16, i1 false)
  %15 = bitcast [16 x i8]* %comm to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %15)
  %16 = bitcast i64* %"@x_key" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %16)
  store i64 0, i64* %"@x_key"
  %pseudo2 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %update_elem = call i64 inttoptr (i64 2 to i64 (i64, i64*, [16 x i8]*, i64)*)(i64 %pseudo2, i64* %"@x_key", [16 x i8]* %"lookup_$var_map", i64 0)
  %17 = bitcast i64* %"@x_key" to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %17)
  %18 = bitcast i64* %"@y_key" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %18)
  store i64 0, i64* %"@y_key"
  %pseudo3 = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %update_elem4 = call i64 inttoptr (i64 2 to i64 (i64, i64*, [16 x i8]*, i64)*)(i64 %pseudo3, i64* %"@y_key", [16 x i8]* %"lookup_$var_map", i64 0)
  %19 = bitcast i64* %"@y_key" to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %19)
  ret i64 0
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i1) #1

attributes #0 = { nounwind }
attributes #1 = { argmemonly nounwind }
