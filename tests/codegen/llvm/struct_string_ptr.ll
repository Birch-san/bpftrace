; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64, i64) #0

define i64 @"kprobe:f"(i8*) section "s_kprobe:f_1" {
entry:
  %"@mystr_key" = alloca i64
  %"struct Foo.str" = alloca i64
  %strlen = alloca i64
  %helper_error_t = alloca %helper_error_t
  %key = alloca i32
  %"$foo" = alloca i64
  %1 = bitcast i64* %"$foo" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %1)
  store i64 0, i64* %"$foo"
  %2 = bitcast i64* %"$foo" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %2)
  store i64 0, i64* %"$foo"
  %3 = bitcast i32* %key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %3)
  store i32 0, i32* %key
  %pseudo = call i64 @llvm.bpf.pseudo(i64 1, i64 3)
  %lookup_str_map = call [64 x i8]* inttoptr (i64 1 to [64 x i8]* (i64, i32*)*)(i64 %pseudo, i32* %key)
  %4 = sext [64 x i8]* %lookup_str_map to i32
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
  %12 = bitcast i64* %strlen to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %12)
  store i64 64, i64* %strlen
  %13 = load i64, i64* %"$foo"
  %14 = add i64 %13, 0
  %15 = bitcast i64* %"struct Foo.str" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %15)
  %probe_read = call i64 inttoptr (i64 4 to i64 (i64*, i32, i64)*)(i64* %"struct Foo.str", i32 8, i64 %14)
  %16 = load i64, i64* %"struct Foo.str"
  %17 = bitcast i64* %"struct Foo.str" to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %17)
  %18 = bitcast [64 x i8]* %lookup_str_map to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %18, i64 0, i64 64, i1 false)
  %19 = load i64, i64* %strlen
  %probe_read_str = call i64 inttoptr (i64 45 to i64 ([64 x i8]*, i32, i64)*)([64 x i8]* %lookup_str_map, i64 %19, i64 %16)
  %20 = bitcast i64* %strlen to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %20)
  %21 = bitcast i64* %"@mystr_key" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %21)
  store i64 0, i64* %"@mystr_key"
  %pseudo2 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %update_elem = call i64 inttoptr (i64 2 to i64 (i64, i64*, [64 x i8]*, i64)*)(i64 %pseudo2, i64* %"@mystr_key", [64 x i8]* %lookup_str_map, i64 0)
  %22 = bitcast i64* %"@mystr_key" to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %22)
  ret i64 0
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1) #1

attributes #0 = { nounwind }
attributes #1 = { argmemonly nounwind }
