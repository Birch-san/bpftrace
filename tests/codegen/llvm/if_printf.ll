; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "bpf-pc-linux"

%helper_error_t = type <{ i64, i64, i32, i8 }>
%printf_t = type { i64, i64 }

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64 %0, i64 %1) #0

define i64 @"kprobe:f"(i8* %0) section "s_kprobe:f_1" {
entry:
  %helper_error_t = alloca %helper_error_t, align 8
  %lookup_fmtstr_key = alloca i32, align 4
  %get_pid_tgid = call i64 inttoptr (i64 14 to i64 ()*)()
  %1 = lshr i64 %get_pid_tgid, 32
  %2 = icmp ugt i64 %1, 10000
  %3 = zext i1 %2 to i64
  %true_cond = icmp ne i64 %3, 0
  br i1 %true_cond, label %if_body, label %if_end

if_body:                                          ; preds = %entry
  %4 = bitcast i32* %lookup_fmtstr_key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %4)
  store i32 0, i32* %lookup_fmtstr_key, align 4
  %pseudo = call i64 @llvm.bpf.pseudo(i64 1, i64 0)
  %lookup_fmtstr_map = call %printf_t* inttoptr (i64 1 to %printf_t* (i64, i32*)*)(i64 %pseudo, i32* %lookup_fmtstr_key)
  %5 = bitcast i32* %lookup_fmtstr_key to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %5)
  %6 = sext %printf_t* %lookup_fmtstr_map to i32
  %7 = icmp ne i32 %6, 0
  br i1 %7, label %helper_merge, label %helper_failure

if_end:                                           ; preds = %helper_merge, %entry
  ret i64 0

helper_failure:                                   ; preds = %if_body
  %8 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %8)
  %9 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 0
  store i64 30006, i64* %9, align 8
  %10 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 1
  store i64 0, i64* %10, align 8
  %11 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 2
  store i32 %6, i32* %11, align 4
  %12 = getelementptr %helper_error_t, %helper_error_t* %helper_error_t, i64 0, i32 3
  store i8 1, i8* %12, align 1
  %pseudo1 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %helper_error_t*, i64)*)(i8* %0, i64 %pseudo1, i64 4294967295, %helper_error_t* %helper_error_t, i64 21)
  %13 = bitcast %helper_error_t* %helper_error_t to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %13)
  ret i64 0

helper_merge:                                     ; preds = %if_body
  %14 = bitcast %printf_t* %lookup_fmtstr_map to i8*
  call void @llvm.memset.p0i8.i64(i8* align 1 %14, i8 0, i64 16, i1 false)
  %15 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i32 0, i32 0
  store i64 0, i64* %15, align 8
  %get_pid_tgid2 = call i64 inttoptr (i64 14 to i64 ()*)()
  %16 = lshr i64 %get_pid_tgid2, 32
  %17 = getelementptr %printf_t, %printf_t* %lookup_fmtstr_map, i32 0, i32 1
  store i64 %16, i64* %17, align 8
  %pseudo3 = call i64 @llvm.bpf.pseudo(i64 1, i64 1)
  %perf_event_output4 = call i64 inttoptr (i64 25 to i64 (i8*, i64, i64, %printf_t*, i64)*)(i8* %0, i64 %pseudo3, i64 4294967295, %printf_t* %lookup_fmtstr_map, i64 16)
  br label %if_end
}

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg %0, i8* nocapture %1) #1

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg %0, i8* nocapture %1) #1

; Function Attrs: argmemonly nofree nosync nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly %0, i8 %1, i64 %2, i1 immarg %3) #2

attributes #0 = { nounwind }
attributes #1 = { argmemonly nofree nosync nounwind willreturn }
attributes #2 = { argmemonly nofree nosync nounwind willreturn writeonly }
