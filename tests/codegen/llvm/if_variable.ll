; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>
%printf_t = type { i64, i64 }

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64, i64) #0

define i64 @"kprobe:f"(i8*) section "s_kprobe:f_1" {
entry:
  %helper_error_t = alloca %helper_error_t
  %key = alloca i32
  %"$s" = alloca i64
  %1 = bitcast i64* %"$s" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %1)
  store i64 0, i64* %"$s"
  %get_pid_tgid = call i64 inttoptr (i64 14 to i64 ()*)()
  %2 = lshr i64 %get_pid_tgid, 32
  %3 = icmp ugt i64 %2, 10000
  %4 = zext i1 %3 to i64
  %true_cond = icmp ne i64 %4, 0
  br i1 %true_cond, label %if_body, label %if_end

if_body:                                          ; preds = %entry
  %5 = bitcast i64* %"$s" to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %5)
  store i64 10, i64* %"$s"
  br label %if_end

if_end:                                           ; preds = %if_body, %entry
  %6 = bitcast i32* %key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %6)
  store i32 0, i32* %key
  %pseudo = call i64 @llvm.bpf.pseudo(i64 1, i64 2)
  %lookup_fmtstr_map = call %printf_t* inttoptr (i64 1 to %printf_t* (i64, i32*)*)(i64 %pseudo, i32* %key)
  %7 = sext %printf_t* %lookup_fmtstr_map to i32
  %8 = icmp ne i32 %7, 0
  br i1 %8, label %helper_merge, label %helper_failure

helper_failure:                                   ; preds = %if_end
  %9 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %9)
  %10 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 0
  store i64 30006, i64* %10
  %11 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 1
  store i64 0, i64* %11
  %12 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 2
  store i32 %7, i32* %12
  %13 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 3
  store i8 1, i8* %13
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo1, i64 4294967295, %helper_error_t* %helper_error_t, i64 21)
  %14 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %14)
  ret i64 0

helper_merge:                                     ; preds = %if_end
  %15 = bitcast %printf_t* %lookup_fmtstr_map to i8*
  call void @llvm.memset.p0i8.i64(i8* align 8 %15, i64 0, i64 16, i1 false)
  %16 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i32 0, i32 0
  store i64 0, i64* %16
  %17 = load i64, i64* %"$s"
  %18 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i32 0, i32 1
  store i64 %17, i64* %18
  %pseudo2 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output3 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %printf_t*, i64)*)(i8* %0, i64 %pseudo2, i64 4294967295, %printf_t* %lookup_fmtstr_map, i64 16)
  %19 = bitcast %printf_t* %lookup_fmtstr_map to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %19)
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
