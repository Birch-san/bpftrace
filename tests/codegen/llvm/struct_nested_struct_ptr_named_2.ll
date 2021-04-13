; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf-pc-linux"

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64, i64) #0

define i64 @"kprobe:f"(i8*) section "s_kprobe:f_1" {
entry:
  %"@x_val" = alloca i64
  %"@x_key" = alloca i64
  %"struct Bar.x" = alloca i32
  %"struct Foo.bar" = alloca i64
  %"$foo" = alloca i64
  %1 = bitcast i64* %"$foo" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %1)
  store i64 0, i64* %"$foo"
  %2 = bitcast i8* %0 to i64*
  %3 = getelementptr i64, i64* %2, i64 14
  %arg0 = load volatile i64, i64* %3
  store i64 %arg0, i64* %"$foo"
  %4 = load i64, i64* %"$foo"
  %5 = add i64 %4, 0
  %6 = bitcast i64* %"struct Foo.bar" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %6)
  %probe_read_kernel = call i64 inttoptr (i64 113 to i64 (i64*, i32, i64)*)(i64* %"struct Foo.bar", i32 8, i64 %5)
  %7 = load i64, i64* %"struct Foo.bar"
  %8 = bitcast i64* %"struct Foo.bar" to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %8)
  %9 = add i64 %7, 0
  %10 = bitcast i32* %"struct Bar.x" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %10)
  %probe_read_kernel1 = call i64 inttoptr (i64 113 to i64 (i32*, i32, i64)*)(i32* %"struct Bar.x", i32 4, i64 %9)
  %11 = load i32, i32* %"struct Bar.x"
  %12 = sext i32 %11 to i64
  %13 = bitcast i32* %"struct Bar.x" to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %13)
  %14 = bitcast i64* %"@x_key" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %14)
  store i64 0, i64* %"@x_key"
  %15 = bitcast i64* %"@x_val" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %15)
  store i64 %12, i64* %"@x_val"
  %pseudo = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %update_elem = call i64 inttoptr (i64 2 to i64 (i64, i64*, i64*, i64)*)(i64 %pseudo, i64* %"@x_key", i64* %"@x_val", i64 0)
  %16 = bitcast i64* %"@x_key" to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %16)
  %17 = bitcast i64* %"@x_val" to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %17)
  ret i64 0
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) #1

attributes #0 = { nounwind }
attributes #1 = { argmemonly nounwind }
